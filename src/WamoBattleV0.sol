// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev DESIGN NOTES
 * For complex input validations use if statements + revert + custom errors;
 * use require statements only for simple checks
 *    - (reverts save gas apparently, plus more precise error messages)
 *
 * @dev create game -> stake wamo -> game start -> player 1 move
 * @dev GameStatus is the switch which allows certain functionality; 
    GameStatus must only be mutated to ONFOOT when the two players have
    staked their wamos
    @dev GameStatus must only be mutated by the implemenation of onERC721Revieved 
 */

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "./WamosRandomnessV0.sol";
import "./WamosV0.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

////////////////////////////////////////////////////////////
/////////////////        STRUCTS       /////////////////////
////////////////////////////////////////////////////////////

// TODO pack struct when all values known
struct GameData {
    uint256 id;
    GameStatus status;
    uint256 startTimestamp;
    uint256 lastTurnTimestamp;
    uint256 turnCount;
    address[2] players;
    mapping(address => uint256) playerId; // \in[0,1]  (necessary?)
    mapping(address => WamoData[]) wamoPartyOf; // array for multiple wamos
    mapping(address => uint256) stakedWamoCount;
}

// TODO stack with all mutable in-game transient stats
struct WamoData {
    uint256 wamoId;
    int8 x;
    int8 y;
    uint256 health;
}
////////////////////////////////////////////////////////////
/////////////////        ERRORS        /////////////////////
////////////////////////////////////////////////////////////

error NotPlayerOfGame(uint256 gameId, address addr);
error GameNotOnfoot(uint256 gameId);
error SenderDoesntOwnWamo(uint256 gameId, address sender, uint256 wamoId);
error WamoStakingFailed(uint256 gameId, address player, uint256 wamoId);
error MaximumWamosStaked(uint256 gameId, address Sender);
error InsufficientWamosStaked(uint256 gameId);

////////////////////////////////////////////////////////////
/////////////////   WAMOS BATTLE V0    /////////////////////
////////////////////////////////////////////////////////////

contract WamosBattleV0 is IERC721Receiver {
    //// GAME CONSTANTS
    int8 public GRID_SIZE = 16;
    int8 public MAX_MOVE = 3;
    int8 public MAX_PLAYERS = 2;
    uint256 public MAX_WAMO_STAKE = 2;

    //// WAMOS TOKEN CONTRACT
    IERC721 public wamos;

    //// WAMOS VRF CONSUMER
    WamosRandomnessV0 private theGods;

    //// GAME STATE STORAGE
    GameData[] public games;
    // player -> gameId of games which player has been challenged to
    // this mapping is mechanism which allows invitation visibility and acceptances
    mapping(address => uint256[]) challengesReceivedBy;
    mapping(address => uint256[]) challengesSentBy;
    // mapping(address => uint256) lastGame;

    // mapping(uint256 => uint256[]) wamosStakedInGame;
    // or
    mapping(uint256 => bool) isWamoStaked;

    ////////////////////////////////////////////////////////////
    /////////////////      TODO EVENTS     /////////////////////
    ////////////////////////////////////////////////////////////

    constructor(IERC721 _nft) {
        wamos = _nft;
    }

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

    ////////////////////////////////////////////////////////////
    /////////////////      GAME SETUP      /////////////////////
    ////////////////////////////////////////////////////////////

    /**
     * @dev kept minimal for modularity and gas minimization in game creation
     */
    function initialiseGame(address challenger, address invitee)
        external
        returns (uint256 gameId)
    {
        uint256 id = games.length;
        GameData storage newgame = games.push();
        newgame.id = id;
        newgame.players = [challenger, invitee];
        newgame.startTimestamp = block.timestamp;
        challengesReceivedBy[invitee].push(gameId);
        challengesSentBy[challenger].push(gameId);
        // newgame.status defaults to 0 PREGAME
        // leave party struct packing for other function
        return id;
    }

    /**
     * @dev TODO upgrade to take multiple wamo ids as input to fill entire party
     *      - maybe function overloading for this
     * @dev Stakes wamo for battle
     * @dev Can function be tricked by sending token id to it that is already staked?
     *
     * Wamo not added to struct here; GameData mutated in onERC721Received instead,
     * to avoid reentrancy, or receiving wamo in this functon call but gas running out
     * before data is added, or noxious outcome if transfer fails for unforseen reason.
     */
    function connectWamo(uint256 gameId, uint256 wamoId)
        external
        returns (bool isSuccesful)
    {
        // require player owns wamo and wamo exists
        if (wamos.ownerOf(wamoId) != msg.sender) {
            revert SenderDoesntOwnWamo(gameId, msg.sender, wamoId);
        }
        // require sufficient number of wamos have not already been staked
        if (games[gameId].stakedWamoCount[msg.sender] >= MAX_WAMO_STAKE) {
            revert MaximumWamosStaked(gameId, msg.sender);
        }
        // prompt receipt of wamo token
        wamos.safeTransferFrom(msg.sender, address(this), wamoId); // from, to, tokenId, data(bytes)
        // check if WamoBattle owns the wamo now
        isWamoStaked[wamoId] = (wamos.ownerOf(wamoId) == address(this));
        // TODO if stake successful, initialise game data
        if (isWamoStaked[wamoId]) {
            WamoData storage wamoData = games[gameId]
                .wamoPartyOf[msg.sender]
                .push();
            wamoData.wamoId = wamoId;
            // TODO init position (separate function probably)
        }
        return isWamoStaked[wamoId];
    }

    /**
     * @dev Must account for security considerations of receiving foreign erc721 tokens
     */
    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function startGame(uint256 gameId) external {
        // ensure two players have connected
        require(
            games[gameId].players[1] != address(0),
            "Game cannot start without two players"
        );
        // ensure players have both staked sufficient wamo nfts
        if (
            games[gameId].stakedWamoCount[games[gameId].players[0]] +
                games[gameId].stakedWamoCount[games[gameId].players[1]] <
            2 * MAX_WAMO_STAKE
        ) {
            revert InsufficientWamosStaked(gameId);
        }
        // change game status to onfoot when requires passed
        games[gameId].status = GameStatus.ONFOOT;
    }

    ////////////////////////////////////////////////////////////
    /////////////////    PLAYER ACTIONS    /////////////////////
    ////////////////////////////////////////////////////////////

    function move() external returns (int8 newX, int8 newY) {
        // ensure it is players turn
        // update last turn timestamp
    }

    function useAbility() external {}

    ////////////////////////////////////////////////////////////
    /////////////////    VIEW FUNCTIONS    /////////////////////
    ////////////////////////////////////////////////////////////

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
