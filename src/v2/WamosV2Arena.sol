// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "~/v2/WamosV2.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

// Tracks each game
struct GameData {
    GameStatus status;
    uint256 createTime;
    uint256 lastMoveTime;
    uint256 turnCount;
    address player1;
    address player2;
    uint256 partySize;
    uint256 party1; // encoded
    uint256 party2;
}

// Tracks the status of a single wamo during a game
struct WamoStatus {
    int16 position;
    uint256 health;
    uint256 stamina;
    uint256 mana;
}

struct StakingStatus {
    bool exists;
    bool stakeRequested;
    bool isStaked;
    uint256 gameId;
}

contract WamosV2Arena is IERC721Receiver {
    //// GAME CONSTANTS
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2; 

    //// WAMOS
    WamosV2 wamos;

    //// GAME CONTRACT DATA
    uint256 public gameCount;

    //// INVITE SYSTEM
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;

    //// PLAYER TAGS
    mapping(address => string) public addrToPlayerTag;

    //// GAME DATA
    // todo
    // game status data
    mapping(uint256 => uint256) gameIdToGameData;
    // wamo status data (if in game)

    //// WAMO STAKING
    // todo
    // wamo staking status
    // wamos taked by players in game

    //// EVENTS
    // todo

    constructor(address _wamosAddr) {
        wamos = WamosV2(_wamosAddr);
    }

    //// MODIFIERS ////

    // todo
    modifier onlyPlayer() {
        _;
    }

    // todo
    modifier onlyOnFoot() {
        _;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////       GAME SET UP       ////////////////////
    /////////////////////////////////////////////////////////////////

    function createGame(address player2) external returns (uint256 gameId) {
        // todo require statements
        address player1 = msg.sender;
        gameId = gameCount++;
        GameData memory game;
        game.createTime = block.timestamp;
        game.players = [player1, player2];
        game.status = GameStatus.PREGAME;
        // encode and store game data
        uint256 gameData = _encodeGameData(game);
        gameIdToGameData[gameId] = gameData;

    }

    // todo batch connection
    function connectWamos(uint256 gameId, uint256[] memory wamoIds) external {}

    function _loadWamos(uint256 gameId, address player) internal {}

    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if (operator == address(this)) {
            uint256 gameId = 10;
        }
        return IERC721Receiver.onERC721Received.selector;
    } 

    /////////////////////////////////////////////////////////////////
    ////////////////////    GAMEPLAY FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function commitTurn() external {}

    function resign() external {}

    function claimVictory() external {}

    function retrieveWamos() external {}

    /////////////////////////////////////////////////////////////////
    //////////////////// INTERNAL GAME FUNCTIONS ////////////////////
    /////////////////////////////////////////////////////////////////

    function _commitTurn() internal {}

    function _changeWamoPosition() internal {}

    function _calculateDamage() internal {}

    function _changeWamoHealth() internal {}

    function _moveWamo() internal {}

    /////////////////////////////////////////////////////////////////
    ////////////////////    CONTRACT SETTERS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////   ENCODING  FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function _encodeGameData(GameData memory game) public returns (uint256 gameData) {}
}
