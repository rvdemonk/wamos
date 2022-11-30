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

contract WamosV2Arena {
    //// GAME CONSTANTS
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2; 
}
