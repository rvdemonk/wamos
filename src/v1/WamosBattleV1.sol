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
    uint256 startTime;
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

contract WamosBattleV1 is IERC721Receiver, VRFConsumerBaseV2 {
    // VRF CONFIGURATION
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    // VRF CONSUMER STORAGE
    mapping(uint256 => VRFRequest) requestIdToRequest;
    uint256[] public requestIds;
    uint256 public lastRequest;

    // VRF COORDINATOR
    VRFCoordinatorV2Interface vrfCoordinator;

    // WAMOS INTERFACE
    WamosV1Interface wamos;

    // GAME CONSTANTS
    int256 public GRID_SIZE = 16;
    uint256 public MAX_PLAYERS = 2;
    uint256 public PARTY_SIZE = 2;

    // GAME CONTRACT DATA
    uint256 public gameCount;
    mapping(uint256 => bool) public wamoIdToIsStaked;
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;

    // GAME STATE STORAGE
    mapping(uint256 => GameData) public gameIdToGameData;
    mapping(uint256 => mapping(address => uint256[2]))
        public gameIdToPlayersWamoParty;

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

    function createGame(address player0, address player1)
        external
        returns (uint256 gameId)
    {
        // gameId = gameCount++;
        GameData storage game;
        game.id = gameCount++;
        return gameId;
    }

    function connectWamo() external {}

    function move() external {}

    function useAbility() external {}

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
