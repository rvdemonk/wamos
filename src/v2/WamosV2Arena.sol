// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

/**
    create or join game - stake party - play - retrieve party
    TODO encode all storage
 */

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

enum StakingStatus {
    UNSTAKED,
    REQUESTED,
    STAKED
}

// Tracks each game
struct GameData {
    address[2] players; //0->player1, 1->player2
    GameStatus status;
    uint256 partySize;
    bool party1IsStaked;
    bool party2IsStaked;
    uint256 createTime;
    uint256 lastMoveTime;
    uint256 turnCount;
}

// Tracks the status of a single wamo during a game
struct WamoStatus {
    bool inArena;
    int16 position;
    uint256 health;
    uint256 stamina;
    uint256 mana;
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
    // game data (struct, temporary)
    mapping(uint256 => GameData) gameIdToGameDataStruct;
    // game data (encoded)
    mapping(uint256 => uint256) gameIdToGameData;
    // wamo staking status
    mapping(uint256 => StakingStatus) wamoIdToStakingStatus;
    // wamo status (encoded)
    mapping(uint256 => uint256) wamoIdToWamoStatus;

    //// EVENTS todo

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

    function createGame(
        address player2,
        uint256 partySize
    ) external returns (uint256 gameId) {
        // todo require statements
        address player1 = msg.sender;
        gameId = gameCount++;
        GameData memory game;
        game.createTime = block.timestamp;
        game.partySize = partySize;
        game.players = [player1, player2];
        game.status = GameStatus.PREGAME;

        // // encode game data
        // uint256 gameData = _encodeGameData(game);
        // gameIdToGameData[gameId] = gameData;

        // todo temporary
        gameIdToGameDataStruct[gameId] = game;
    }

    // @dev atm only build for party size of three
    function connectWamos(uint256 gameId, uint256[3] memory wamoIds) external {
        // todo requirements

        for (uint i = 0; i < wamoIds.length; i++) {
            wamoIdToStakingStatus[wamoIds[i]] = StakingStatus.REQUESTED;
            // prompt transfr
            wamos.safeTransferFrom(msg.sender, address(this), wamoIds[i]);
            _loadWamo(gameId, msg.sender, wamoIds[i]);
        }

        if (msg.sender == gameIdToGameDataStruct[gameId].players[0]) {
            gameIdToGameDataStruct[gameId].party1IsStaked = true;
        } else {
            gameIdToGameDataStruct[gameId].party2IsStaked = true;
        }

        _assessGameStatus(gameId);
    }

    // @dev load wamos together or one at a time? loadwamo or loadwamos??
    function _loadWamo(
        uint256 gameId, 
        address player, 
        uint256 wamoId
    ) internal {
        // check wamos have been received?
        // if so, register stake success status

        // load wamo traits
        Traits memory traits = wamos.getTraits(wamoId);
        uint256 wamoStatus;

        // if player is p1, starting position 0; else 255

        // in arena
        wamoStatus |= uint256(1) << 8;
        // starting position
        // wamoStatus |= uint256(startingPos) << 16;
        // extract relevant and encode
        wamoStatus |= traits.health << 24;
        wamoStatus |= traits.mana << 32;
        wamoStatus |= traits.stamina << 40;

        wamoIdToWamoStatus[wamoId] = wamoStatus;
    }

    function _assessGameStatus(uint256 gameId) internal {
        // if both parties are staked -> set game status to onfoot
        GameData memory game = gameIdToGameDataStruct[gameId];
        if (game.party1IsStaked && game.party2IsStaked) {
            gameIdToGameDataStruct[gameId].status = GameStatus.ONFOOT;
        }
    }

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
    ////////////////////    ENCODING FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function _encodeGameData(
        GameData memory game
    ) public returns (uint256 gameData) {}

    /////////////////////////////////////////////////////////////////
    ////////////////////      VIEW FUNCTIONS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function getGameStatus(
        uint256 gameId
    ) public view returns (GameStatus status) {
        status = gameIdToGameDataStruct[gameId].status;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    CONTRACT SETTERS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////   ENCODING  FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////
}
