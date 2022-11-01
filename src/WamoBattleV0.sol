// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev DESIGN NOTES
 * For complex input validations use if statements + revert + custom errors;
 * use require statements only for simple checks
 *    - (reverts save gas apparently, plus more precise error messages)
 *
 */

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "./WamosRandomnessV0.sol";
import "./WamosTokenV0.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

// TODO pack struct when all values known
struct GameData {
    uint256 id;
    GameStatus status;
    uint256 startTimestamp;
    uint256 lastTurnTimestamp;
    uint256 turnCount;
    address[2] players;
    mapping(address => uint256) playerId; // needed?
    mapping(address => WamoData[]) playerParty;
}

// TODO stack with mutable in-game transient stats
struct WamoData {
    int8 x;
    int8 y;
    uint256 health;
}

error NotPlayerOfGame(uint256 gameId, address addr);
error GameNotOnfoot(uint256 gameId);

// error GameNotStarted(uint256 gameId);
// error GameFinished(uint256 gameId);

contract WamosBattleV0 is IERC721Receiver {
    //// GAME CONSTANTS
    int8 public GRID_SIZE = 16;
    int8 public MAX_MOVE = 3;
    int8 public MAX_PLAYERS = 2;

    //// WAMOS TOKEN CONTRACT
    IERC721 public wamosNFT;

    //// WAMOS VRF CONSUMER
    WamosRandomnessV0 private wamosRandomness;

    //// GAME STATE STORAGE
    GameData[] public games;
    mapping(address => uint256) mostRecentGameId;

    /////////////////
    // TODO EVENTS //
    /////////////////

    // Reverts function if msg.sender is not a player of gameId
    modifier onlyPlayer(uint256 gameId) {
        if (games[gameId].playerId[msg.sender] == 0) {
            revert NotPlayerOfGame(gameId, msg.sender);
        }
        _;
    }

    // Reverts function if gameId has not started or has finished
    modifier onlyOnfootGame(uint256 gameId) {
        if (games[gameId].status != GameStatus.ONFOOT) {
            revert GameNotOnfoot(gameId);
        }
        _;
    }

    constructor(IERC721 _nft) {
        wamosNFT = _nft;
    }

    // override for erc721 receiver
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        require(msg.sender == address(wamosNFT));
        return IERC721Receiver.onERC721Received.selector;
    }

    function createGame(address player1, address invitee)
        external
        returns (uint256 gameId)
    {}

    function startGame(uint256 gameId) external {}

    function endGame(uint256 gameId) external {}

    function move() external returns (int8 newX, int8 newY) {}

    function useAbility() external {}

    function getPlayers(uint256 gameId)
        public
        view
        returns (address[2] memory players)
    {}

    function getGameStatus(uint256 gameId) public view returns (GameStatus) {
        return games[gameId].status;
    }

    function getGameCount() public view returns (uint256) {
        return games.length;
    }

    function getWamoPosition() public view returns (int8 x, int8 y) {}

    function getWamo() public {}

    function getStakedWamoId() public {}

    function abs(int8 z) public pure returns (int8) {
        return z >= 0 ? z : -z;
    }
}
