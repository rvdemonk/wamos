// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";

/*
WAMO ATTRIBUTES \in [0, 2^8 - 1]
Vigor ->(attack)
Guard -> (defence)
Agility -> effects movement speed and distance
Wisdom -> effects magic
Luck 
Movement pattern (special attribute, from smaller set)
Type
*/

enum Types {
    ZEUS,
    POSEIDON,
    HADES,
    APOLLO,
    ATHENA,
    ARES,
    HERMES
}

struct Ability {
    uint8 Type;
    uint8 Attack;
    uint8 Defence;
    uint8 MagicAttack;
    uint8 MagicDefence;
    uint8 Speed;
    uint8 Accuracy;
    uint8 PP;
    uint8 Cooldown;
}

contract ProtoWamos is ERC721 {
    // META CONSTANTS
    string public NAME = "ProtoWAMOS";
    string public SYMBOL = "pWAMOs";

    // WAMO DATA STORAGE: WamoID => (value)
    mapping(uint256 => uint8[]) attributes;
    mapping(uint256 => Ability[]) abilities;

    constructor() ERC721(NAME, SYMBOL) {}

    function spawn() public returns (uint256) {}

    function requestRandomness() public {}

    function fulfilRandomness() public {}
}
