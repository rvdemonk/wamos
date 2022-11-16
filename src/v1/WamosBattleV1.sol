// SPDX-License-Identifier: MIT

/**
 * @dev WAMOS BATTLE V1 SET UP
 * deploy wamos -> deploy wamos battle -> users approve battle staking in wamos
 *
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
import "src/v1/WamosV1.sol";

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
error InvalidAbilityIndex(uint256 gameId, address player);
error InvalidMoveIndex(uint256 gameId, address player);
error WamoHasNoHealth(uint256 gameId, uint256 wamoId);
error WamoNotInGame(uint256 gameId, uint256 wamoId);
error NotPlayersTurn(uint256 gameId, address player);

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
    WamosV1 wamos;

    /** GAME CONSTANTS */
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2;

    /** GAME CONTRACT DATA */
    uint256 public gameCount;
    // staking
    mapping(uint256 => StakingStatus) public wamoIdToStakingStatus;
    // number of wamos staked in gameId x by player y
    mapping(uint256 => mapping(address => uint256)) gameIdToPlayerToStakedCount;

    // invite system
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;
    
    // player name
    mapping(address => string) public addrToPlayerTag;

    /** GAME STATE STORAGE */
    //// META GAME
    // is player y ready in game x
    mapping(uint256 => mapping(address => bool)) public gameIdToPlayerIsReady;
    
    ///// GAME 
    // game data
    mapping(uint256 => GameData) public gameIdToGameData;
    // ids of wamos in player y party for game id x
    mapping(uint256 => mapping(address => uint256[PARTY_SIZE]))
        public gameIdToPlayerToWamoPartyIds;
    // the state of wamo y in game x
    mapping(uint256 => mapping(uint256 => WamoStatus))
        public gameIdToWamoIdToStatus;
    // for game x, token id of wamo on index y, 0 if none
    mapping(uint256 => mapping(int16 => uint256)) gameIdToGridIndexToWamoId;

    constructor(
        address _wamosAddr,
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        // instantiate wamos interface
        wamos = WamosV1(_wamosAddr);
        // instantiate vrf coordinator interface
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        // configure coordinator variables
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfNumWords = 1;
        vrfCallbackGasLimit = 100000;
        vrfRequestConfirmations = 2;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////        MODIFIERS        ////////////////////
    /////////////////////////////////////////////////////////////////

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

    /** @notice Reverts function if game gameId is not onfoot */
    modifier onlyOnfootGame(uint256 gameId) {
        if (gameIdToGameData[gameId].status != GameStatus.ONFOOT) {
            revert GameIsNotOnfoot(gameId);
        }
        _;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////       GAME SET UP       ////////////////////
    /////////////////////////////////////////////////////////////////

    /**
     * @return id of new game created.
     */
    function createGame(address challengee) external returns (uint256) {
        address challenger = msg.sender;
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
            gameIdToPlayerToStakedCount[gameId][msg.sender] < PARTY_SIZE,
            "Maximum Wamos already staked!"
        );
        // check that sender owns wamo
        if (wamos.ownerOf(wamoId) != msg.sender) {
            revert PlayerDoesNotOwnThisWamo(wamoId, msg.sender);
        }
        // prompt wamo transfer
        // increment staked count
        gameIdToPlayerToStakedCount[gameId][msg.sender]++;
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
        wamos.safeTransferFrom(msg.sender, address(this), wamoId); // from, to, tokenId, data(bytes)
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
        _loadWamos(gameId, msg.sender);
        gameIdToPlayerIsReady[gameId][msg.sender] = true;
        // if both players ready: game started?
        // @dev TODO does this make gas ridik????
        // todo simply see if other player is ready -- this player is clearly ready
        address challenger = gameIdToGameData[gameId].challenger;
        address challengee = gameIdToGameData[gameId].challengee;
        // if both players are ready set the game status to onfoot
        if (
            gameIdToPlayerIsReady[gameId][challenger] &&
            gameIdToPlayerIsReady[gameId][challengee]
        ) {
            gameIdToGameData[gameId].status = GameStatus.ONFOOT;
        }
    }

    function _loadWamos(uint256 gameId, address player) internal {
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

    /////////////////////////////////////////////////////////////////
    ////////////////////    GAMEPLAY FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    /**
     * @notice mutates wamos position from a selection of movement possiblities 
     *          according to wamo trait
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

    /**
     * @dev move and use ability in a single function call
     *  Design choice would save time (ie one transaction instead of two), however
     *  would likely increase gas, due to the number of require statements needed to
     *  confirm permissibility of move + ability combo.
     */
    function commitTurn(
        uint256 gameId,
        uint256 wamoId,
        uint256 moveChoice,
        uint256 abilityChoice,
        uint256 targetGridIndex,
        bool moveBeforeAbility
    ) external onlyPlayer(gameId) onlyOnfootGame(gameId) {
        // player must be in game
        // game must be onfoot <-safety switch: should ensure wamos staked, players readied
        //-----//
        require(targetGridIndex < 256, "Target square must be on the grid!");
        // indices of move and ability must be within valid range
        if (abilityChoice >= wamos.ABILITY_SLOTS()) {
            revert InvalidAbilityIndex(gameId, msg.sender);
        }
        if (moveChoice >= wamos.MOVE_CHOICE()) {
            revert InvalidMoveIndex(gameId, msg.sender);
        }
        // wamo must be in party
        if (!wamoIdToStakingStatus[wamoId].isStaked) {
            revert WamoNotInGame(gameId, wamoId);
        }
        // wamo must be alive -> simple return, end function immediately?
        if (gameIdToWamoIdToStatus[gameId][wamoId].health == 0) {
            revert WamoHasNoHealth(gameId, wamoId);
        }
        // target is within range 
        // todo
        // it is players turn (challenger moves first)
        uint256 turnCount = gameIdToGameData[gameId].turnCount;
        if ((msg.sender == gameIdToGameData[gameId].challenger 
                && turnCount % 2 == 1 )
                || (msg.sender == gameIdToGameData[gameId].challengee 
                && turnCount % 2 == 0 )) {
                revert NotPlayersTurn(gameId, msg.sender);
            }
        // turn logic //
        ///////
        //////
        //////
        /////
    }


    /////////////////////////////////////////////////////////////////
    //////////////////// INTERNAL GAME FUNCTIONS ////////////////////
    /////////////////////////////////////////////////////////////////

    function _setWamoPosition(
        uint256 gameId,
        uint256 wamoId,
        int16 newIndex
    ) internal {
        gameIdToWamoIdToStatus[gameId][wamoId].positionIndex = newIndex;
    }

    // TODO
    function _endGame(uint256 gameId) internal {
        // alter wamos record
        // distribute spoils
        // return wamos to players
        // toggle staking status to unstaked
        // toggle game status to finished
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     VIEW FUNCTIONS      ////////////////////
    /////////////////////////////////////////////////////////////////

    function getPlayerStakedCount(uint256 gameId, address player) public view returns (uint256 wamosStaked) {
        wamosStaked = gameIdToPlayerToStakedCount[gameId][player];
        return wamosStaked;
    } 

    function isPlayerReady(uint256 gameId, address player) public view returns (bool) {
        return gameIdToPlayerIsReady[gameId][player];
    }

    function getGameData(uint256 gameId) public view returns (GameData memory) {
        if (gameId >= gameCount) {
            revert GameDoesNotExist(gameId);
        }
        return gameIdToGameData[gameId];
    }

    function getGameStatus(uint256 gameId) public view returns (GameStatus) {
        return gameIdToGameData[gameId].status;
    }

    function getPlayerParty(uint256 gameId, address player)
        public
        view
        returns (uint256[PARTY_SIZE] memory wamoIds)
    {
        wamoIds = gameIdToPlayerToWamoPartyIds[gameId][player];
        return wamoIds;
    }

    // @notice TODO reconsider returning an array here? tooo gassy? how else though?
    function getChallengesReceivedBy(address player)
        public
        view
        returns (uint256[] memory)
    {
        return addrToChallengesReceived[player];
    }

    function getChallengesSentBy(address player) public view returns (uint256[] memory)
    {
        return addrToChallengesSent[player];
    }

    // TODO new mapping? wamoId => positionIndex.
    // no need for nested mapping as wamo could only be in one game at a time?
    function getWamoPosition(uint256 gameId, uint256 wamoId) public view returns (int16 positionIndex) {
        positionIndex = gameIdToWamoIdToStatus[gameId][wamoId].positionIndex;
        return positionIndex;
    }

    /** 
     * @notice Returns the wamoID of the wamo occupying the specified grid tile index
     * @notice If the tile is unnocupied, a 0 is returned.
     */
    function getGridTileOccupant(uint256 gameId, int16 gridIndex) public view returns (uint256 wamoId) {
        wamoId = gameIdToGridIndexToWamoId[gameId][gridIndex];
        return wamoId;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    CONTRACT SETTERS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////   OVERRIDE FUNCTIONS    ////////////////////
    /////////////////////////////////////////////////////////////////

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}
}
