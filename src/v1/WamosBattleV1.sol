// SPDX-License-Identifier: MIT

/**
 * @dev WAMOS BATTLE V1: USAGE
 * create game -> connect wamos -> players ready -> game starts -> take turns... -> conquest/resignation
 *
 * @dev CHANGES FROM V0
 *  - Games stored in mapping instead of array for efficiency (arrays must be iterated over
 *    in solidity to find the specified index).
 *
 */

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "src/v1/interfaces/WamosV1Interface.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

/** @notice Stores state variables of game */
struct GameData {
    uint256 id;
    GameStatus status;
    uint256 createTime;
    uint256 lastMoveTime;
    uint256 turnCount;
    address[2] players;
    address challenger;
    address challengee;
}

/** @notice Stores and tracks state of a single Wamo during a battle  */
struct WamoStatus {
    // incomplete
    int16 positionIndex;
    uint256 health;
}

/** @notice Stores status, source and outcome of vrf requests */
struct VRFRequest {
    bool exists;
    bool fulfilled;
    uint256 gameId;
    uint256 turnId;
    uint256 randomWord;
}

/** @notice Tracks the staking request status and staking status of a wamo */
struct StakingStatus {
    bool exists;
    bool stakeRequested;
    uint256 gameId;
    bool isStaked;
}

error GameDoesNotExist(uint256 gameId);
error NotPlayerOfGame(uint256 gameId, address addr);
error PlayerDoesNotOwnThisWamo(uint256 wamoId, address player);
error GameIsNotOnfoot(uint256 gameId);
error WamoMovementNotFound(uint256 gameId, uint256 wamoId, int16 indexMutation);

contract WamosBattleV1 is IERC721Receiver, VRFConsumerBaseV2 {
    /** VRF CONSUMER CONFIG */
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    /** VRF CONSUMER DATA */
    mapping(uint256 => VRFRequest) requestIdToRequest;
    uint256[] public requestIds;
    uint256 public lastRequest;

    /** VRF COORDINATOR INTERFACE */
    VRFCoordinatorV2Interface vrfCoordinator;

    /** WAMOS INTERFACE */
    WamosV1Interface wamos;

    /** GAME CONSTANTS */
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2;

    /** GAME CONTRACT DATA */
    uint256 public gameCount;
    // staking
    mapping(uint256 => StakingStatus) public wamoIdToStakingStatus;
    // invite system
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;
    // player name
    mapping(address => string) public addrToPlayerTag;

    /** GAME STATE STORAGE */
    // game data
    mapping(uint256 => GameData) public gameIdToGameData;
    // number of wamos staked in gameId x by player y
    mapping(uint256 => mapping(address => uint256))
        public gameIdToPlayerToStakedCount;
    // is player y ready in game x
    mapping(uint256 => mapping(address => bool)) public gameIdToPlayerIsReady;
    // ids of wamos in player y party for game id x
    mapping(uint256 => mapping(address => uint256[PARTY_SIZE]))
        public gameIdToPlayerToWamoPartyIds;
    // the state of wamo y in game x
    mapping(uint256 => mapping(uint256 => WamoStatus))
        public gameIdToWamoIdToStatus;

    constructor(
        address _wamosAddr,
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        // instantiate wamos interface
        wamos = WamosV1Interface(_wamosAddr);
        // instantiate vrf coordinator interface
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        // configure coordinator variables
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfNumWords = 1;
        vrfCallbackGasLimit = 100000;
        vrfRequestConfirmations = 2;
    }

    ////////////////    MODIFIERS   ////////////////

    /** @notice Reverts function if msg.sender is not a player of gameId */
    modifier onlyPlayer(uint256 gameId) {
        if (
            gameIdToGameData[gameId].challenger != msg.sender &&
            gameIdToGameData[gameId].challengee != msg.sender
        ) {
            revert NotPlayerOfGame(gameId, msg.sender);
        }
        _;
    }

    modifier onlyOnfootGame(uint256 gameId) {
        if (gameIdToGameData[gameId].status != GameStatus.ONFOOT) {
            revert GameIsNotOnfoot(gameId);
        }
        _;
    }

    ////////////////    GAME SETUP   ////////////////

    /**
     * @return id of new game created.
     */
    function createGame(address challenger, address challengee)
        external
        returns (uint256)
    {
        // initialise gamedata struct
        GameData memory game;
        game.id = gameCount++;
        game.players = [challenger, challengee];
        game.challenger = challenger;
        game.challengee = challengee;
        game.createTime = block.timestamp;
        game.status = GameStatus.PREGAME;
        // store game data
        gameIdToGameData[game.id] = game;
        // store challenge
        addrToChallengesSent[challenger].push(game.id);
        addrToChallengesReceived[challengee].push(game.id);
        return game.id;
    }

    // TODO allow for connection of multiple wamos at once to save gas
    function connectWamo(uint256 gameId, uint256 wamoId)
        external
        onlyPlayer(gameId)
    {
        // TODO custom errors
        // check wamo is not already staked
        require(
            !wamoIdToStakingStatus[wamoId].isStaked,
            "Wamo is already staked!"
        );
        // check max wamos already not staked
        require(
            gameIdToPlayerToStakedCount[gameId][msg.sender] <= PARTY_SIZE,
            "Maximum Wamos already staked!"
        );
        // check that sender owns wamo
        if (wamos.ownerOf(wamoId) != msg.sender) {
            revert PlayerDoesNotOwnThisWamo(wamoId, msg.sender);
        }
        // prompt wamo transfer
        wamos.safeTransferFrom(msg.sender, address(this), wamoId); // from, to, tokenId, data(bytes)
        // register staking request
        if (wamoIdToStakingStatus[wamoId].exists) {
            wamoIdToStakingStatus[wamoId].stakeRequested = true;
            wamoIdToStakingStatus[wamoId].gameId = gameId;
            wamoIdToStakingStatus[wamoId].isStaked = false;
        } else {
            wamoIdToStakingStatus[wamoId] = StakingStatus({
                exists: true,
                stakeRequested: true,
                gameId: gameId,
                isStaked: false
            });
        }
    }

    function playerReady(uint256 gameId) external onlyPlayer(gameId) {
        // TODO custom errors
        // require: game must be pregame
        require(
            gameIdToGameData[gameId].status == GameStatus.PREGAME,
            "Must be pregame to start"
        );
        // require: sufficient wamos must be staked
        require(
            gameIdToPlayerToStakedCount[gameId][msg.sender] == PARTY_SIZE,
            "Player cannot be ready until sufficient wamos staked"
        );
        // load wamos data
        loadWamos(gameId, msg.sender);
        // if both players ready: game started?
        // @dev TODO does this make gas ridik????
        address challenger = gameIdToGameData[gameId].challenger;
        address challengee = gameIdToGameData[gameId].challengee;
        if (
            gameIdToPlayerIsReady[gameId][challenger] &&
            gameIdToPlayerIsReady[gameId][challengee]
        ) {
            gameIdToGameData[gameId].status = GameStatus.ONFOOT;
        }
    }

    function loadWamos(uint256 gameId, address player) internal {
        uint256[PARTY_SIZE] memory party = gameIdToPlayerToWamoPartyIds[gameId][
            player
        ];

        // for each wamo in the party load wamo data
        for (uint256 i = 0; i < PARTY_SIZE; i++) {
            // TODO load full wamo stats when all traits are known
            uint256 wamoId = party[i];

            // starting position
            int16 startPosition;
            if (player == gameIdToGameData[gameId].challenger) {
                startPosition = 0;
            } else {
                startPosition = 255;
            }

            WamoTraits memory traits = wamos.getWamoTraits(wamoId);
            gameIdToWamoIdToStatus[gameId][wamoId] = WamoStatus({
                positionIndex: startPosition,
                health: traits.health
            });
        }
    }

    /**
     * @notice mutates wamos position from a selection of movement possiblities accordint wamo trait
     * @param gameId the id of the game containing the wamo being moved
     * @param wamoId the id of the wamo being moved
     * @param moveTraitIndex the array index of the chosen movement corresponding to the
     *          array of possible movements open to the wamo
     * @return newPosition the position of the wamo after the position mutation
     */
    function move(
        uint256 gameId,
        uint256 wamoId,
        uint256 moveTraitIndex
    )
        external
        onlyPlayer(gameId)
        onlyOnfootGame(gameId)
        returns (int16 newPosition)
    {
        int16[8] memory movements = wamos.getWamoMovements(wamoId);
        int16 mutation = movements[moveTraitIndex];
        newPosition =
            gameIdToWamoIdToStatus[gameId][wamoId].positionIndex +
            mutation;
        _setWamoPosition(gameId, wamoId, newPosition);
        return newPosition;
    }

    /** TODO */
    function useAbility(
        uint256 gameId,
        uint256 wamoId,
        uint256 abilityTraitIndex
    ) external onlyPlayer(gameId) onlyOnfootGame(gameId) {}

    //////////////// GAME SET FUNCTIONS  ////////////////

    function _setWamoPosition(
        uint256 gameId,
        uint256 wamoId,
        int16 newIndex
    ) internal {
        gameIdToWamoIdToStatus[gameId][wamoId].positionIndex = newIndex;
    }

    //////////////// GAME END FUNCTIONS  ////////////////

    // end game
    // return wamos
    // toggle staking requests to not staked and request dne

    //////////////// CONTRACT SET FUNCTIONS  ////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    //////////////// VIEW FUNCTIONS ////////////////

    function getGameData(uint256 gameId) public view returns (GameData memory) {
        if (gameCount >= gameId) {
            revert GameDoesNotExist(gameId);
        }
        return gameIdToGameData[gameId];
    }

    function getChallengesReceivedBy(address player)
        public
        view
        returns (uint256[] memory)
    {
        return addrToChallengesReceived[player];
    }

    // function getWamoPosition()

    // @dev TODO staking logic here
    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // if a wamo has been received
        if (operator == address(wamos)) {
            // match wamo with game and player (from)
            if (wamoIdToStakingStatus[tokenId].stakeRequested) {
                // get game id from staking request struct
                uint256 gameId = wamoIdToStakingStatus[tokenId].gameId;
                uint256 stakedCount = gameIdToPlayerToStakedCount[gameId][from];
                // toggle staked
                wamoIdToStakingStatus[tokenId].isStaked = true;
                // add wamo to players party in game
                // party array is fixed size, so set as index stakedCount
                gameIdToPlayerToWamoPartyIds[gameId][from][
                    stakedCount
                ] = tokenId;
                // add to stake count
                gameIdToPlayerToStakedCount[gameId][from]++;
            }
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}
}
