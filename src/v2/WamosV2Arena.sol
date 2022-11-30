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

    //// WAMO STAKING
    // todo
    // wamo staking status
    // wamos taked by players in game

    //// GAME DATA
    // todo
    // game status data
    // wamo status data (if in game)

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

    function createGame(address challengee) external returns (uint256) {}

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

    function _commitTurn() internal {}

    function _changeWamoPosition() internal {}

    function _calculateDamage() internal {}

    function _changeWamoHealth() internal {}

    // function 
}
