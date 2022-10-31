// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev DESIGN NOTES
 * For complex input validations use if statements + revert + custom errors;
 * use require statements only for simple checks
 *    - (reverts save gas apparently, plus more precise error messages)
 */

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

struct GameData {
    uint256 id;
    uint256 startTimestamp;
    uint256 lastTurnTimestamp;
    uint256 turnCount;
    address[2] players;
    uint256[2] wamoIds;
    GameStatus status;
    mapping(address => int8[2]) positions;
}

struct WamoStatus {
    uint256 health;
    // TODO stack with mutable in-game transient stats
}

// TODO custom errors
error CustomErrorr(uint256 id);

contract WamosBattleV0 is IERC721Receiver {
    //// GAME CONSTANTS
    int8 public GRID_SIZE = 16;
    int8 public MAX_MOVE = 3;
    int8 public MAX_PLAYERS = 2;

    //// WAMOS TOKEN CONTRACT
    IERC721 public wamosNFT;

    //// GAME STATE STORAGE
    GameData[] public games;
    // retrieves ID of the most recent game involving key address
    mapping(address => uint256) mostRecentGameId;

    // TODO events

    // TODO
    modifier onlyPlayer(uint256 gameId) {
        _;
    }

    // TODO
    modifier onlyPlayerOfOnfootGame(uint256 gameId) {
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

    function createGame() external returns (uint256 gameId) {}

    function startGame(uint256 gameId) external {}

    function move() external returns (int8 newX, int8 newY) {}

    function useAbility() external {}

    function getPlayers(uint256 gameId)
        public
        view
        returns (address[2] memory players)
    {}
}
