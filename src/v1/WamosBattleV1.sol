// SPDX-License-Identifier: MIT

/**
 * @dev WAMOS BATTLE V1: USAGE
 * create game -> connect wamos -> start game -> take turns... -> conquest/resignation
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
    // mapping(address => uint256) addrToPlayerId;
    // mapping(address => uint256[]) addrToPartyTokenIds;
}

/** @notice Stores and tracks state of a single Wamo during a battle  */
struct WamoStatus {
    uint256 tokenId;
    uint256 positionIndex;
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

struct StakingStatus {
    bool exists;
    bool stakeRequested;
    uint256 gameId;
    bool isStaked;
}

error GameDoesNotExist(uint256 gameId);
error NotPlayerOfGame(uint256 gameId, address addr);
error PlayerDoesNotOwnThisWamo(uint256 wamoId, address player);

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
    int256 public constant GRID_SIZE = 16;
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
    mapping(uint256 => GameData) public gameIdToGameData;
    mapping(uint256 => mapping(address => uint256))
        public gameIdToPlayerToStakedCount;
    mapping(uint256 => mapping(address => uint256[PARTY_SIZE]))
        public gameIdToPlayerToWamoPartyIds;
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
            gameIdToGameData[gameId].players[0] != msg.sender &&
            gameIdToGameData[gameId].players[1] != msg.sender
        ) {
            revert NotPlayerOfGame(gameId, msg.sender);
        }
        _;
    }

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
        game.createTime = block.timestamp;
        game.status = GameStatus.PREGAME;
        // store game data
        gameIdToGameData[game.id] = game;
        // store challenge
        addrToChallengesSent[challenger].push(game.id);
        addrToChallengesReceived[challengee].push(game.id);
        return game.id;
    }

    function connectWamo(uint256 gameId, uint256 wamoId)
        external
        onlyPlayer(gameId)
    {
        // TODO custom errors
        // check wamo isnt already staked
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

    function move() external {}

    function useAbility() external {}

    //////////////// SET FUNCTIONS  ////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    //////////////// VIEW FUNCTIONS ////////////////

    function getGameData(uint256 gameId)
        external
        view
        returns (GameData memory)
    {
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

    // @dev TODO staking logic here
    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        if (operator == address(wamos)) {
            // wamo received
            // match wamo with game and player (from)
            // record wamo as staked in game
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}
}
