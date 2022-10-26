// SPDX-License-Identifier: MIT
/* 
GRIDGAME3
Changes:
 - creation of a new game does not require redployment of a new contract. Rather,
 now, the mother contract is deployed once, and new games a structs stored in
 a mapping. 
 - no connect function; players "connect" simultaneously when a new game is 
 initialised via the create function.
 - games storage type changed from mapping to array of GameData structs
*/

pragma solidity ^0.8.17;

// struct GameData {
//     uint256 id;
//     uint256 startTimestamp;
//     uint256 lastTurnTimestamp;
//     GameStatus state;
//     uint256 turnCount;
//     address p1;
//     address p2;
//     int8[2] p1_position;
//     int8[2] p2_position;
// }

struct GameData {
    uint256 id;
    uint256 startTimestamp;
    uint256 lastTurnTimestamp;
    GameStatus status;
    uint256 turnCount;
    address[2] players;
    mapping(address => int8[2]) positions;
}

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

// TODO custom errors
// TODO events

contract GridGame3 {
    // CONSTANTS
    int8 public GRID_SIZE = 16;
    int8 public MAX_MOVE = 3;
    int8 public MAX_PLAYERS = 2;

    // STATE VARIABLES
    GameData[] public games;
    uint256 public timestamp;

    constructor() {
        timestamp = block.timestamp;
    }

    // restricts access to a player of the game with gameId
    modifier onlyPlayer(uint256 gameId) {
        require(
            msg.sender == games[gameId].players[0] ||
                msg.sender == games[gameId].players[1],
            "Caller must be player of game"
        );
        _;
    }

    // restricts access to a player of the ONFOOT game with gameId
    modifier onlyPlayerOnfoot(uint256 gameId) {
        require(
            msg.sender == games[gameId].players[0] ||
                msg.sender == games[gameId].players[1],
            "Caller must be player of game"
        );
        require(
            games[gameId].status == GameStatus.ONFOOT,
            "Game referenced must be onfoot"
        );
        _;
    }

    // creates a new game between the two given addresses
    function create(address _p1, address _p2) external returns (uint256) {
        uint256 id = games.length;
        GameData storage newGame = games.push();
        newGame.id = id;
        newGame.startTimestamp = block.timestamp;
        newGame.lastTurnTimestamp = block.timestamp;
        newGame.status = GameStatus.PREGAME;
        newGame.turnCount = 0;
        newGame.players = [_p1, _p2];
        newGame.positions[_p1] = [int8(0), int8(0)];
        newGame.positions[_p2] = [GRID_SIZE - 1, GRID_SIZE - 1];
        // TODO emit event
        return newGame.id;
    }

    function start(uint256 id) external {
        require(
            games[id].status == GameStatus.PREGAME,
            "The game has already started."
        );
        games[id].status = GameStatus.ONFOOT;
    }

    function end(uint256 id) external {
        require(
            games[id].status == GameStatus.ONFOOT,
            "The game must be onfoot to end."
        );
        // TODO game ending condition required?
        games[id].status = GameStatus.FINISHED;
    }

    // only player
    // only onfoot game
    //      ^^ combine these two: onlyActivePlayer?
    // only if players turn
    // only valid move
    //      i within limit and ii within grid
    // **this function will be most frequently called: must be optimised
    // NB: players can both occupy the same tile
    function move(
        uint256 id,
        int8 xMove,
        int8 yMove
    ) external onlyPlayerOnfoot(id) returns (int8, int8) {
        // check that it is players turn
        uint256 turnModulus = games[id].turnCount % 2;
        require(
            games[id].players[turnModulus] == msg.sender,
            "It is not this players turn to move."
        );
        // check that movement is within step limit
        require(
            abs(xMove) + abs(yMove) <= MAX_MOVE,
            "Movement would exceed step limit."
        );
        // check that movement would not cross grid borders
        int8[2] memory oldPos = games[id].positions[msg.sender];
        int8[2] memory newPos = [oldPos[0] + xMove, oldPos[1] + yMove];
        require(
            newPos[0] >= 0 &&
                newPos[0] < GRID_SIZE &&
                newPos[1] >= 0 &&
                newPos[1] < GRID_SIZE,
            "Movement would leave the Battlegrid...trying to escape?"
        );
        games[id].positions[msg.sender] = newPos;
        return (newPos[0], newPos[1]);
    }

    function getPlayers(uint256 gameId)
        public
        view
        returns (address[2] memory)
    {
        return games[gameId].players;
    }

    // TODO change so that returns positions of both players?
    function getPlayerPosition(uint256 gameId, address player)
        public
        view
        returns (int8[2] memory)
    {
        return games[gameId].positions[player];
    }

    function gameCount() public view returns (uint256) {
        return games.length;
    }

    function getGameStatus(uint256 gameId) public view returns (GameStatus) {
        return games[gameId].status;
    }

    function abs(int8 number) public pure returns (int8) {
        return number >= 0 ? number : -number;
    }
}
