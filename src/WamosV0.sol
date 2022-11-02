// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/ConfirmedOwner.sol";

/**
 * @notice PROTOTYPE CONTRACT
 * @notice CONTAINS HARDCODED VALUES
 * @notice NOT FOR PRODUCTION USE!!
 * @dev WAMO ATTRIBUTES, x \in [0, 2^8 - 1]
 * Vigor ->(attack)
 * Guard -> (defence)
 * Agility -> effects movement speed and distance
 * Wisdom -> effects magic
 * Luck
 * SPECIAL ATTRIBUTES
 * Type
 * Movement pattern (special attribute, from smaller set)
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

contract WamosTokenV0 is ERC721, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    //// META CONSTANTS
    string public NAME = "ProtoWAMOS";
    string public SYMBOL = "pWAMOs";

    /* ////////////////////////////////////////////////////////
                WAMO DATA STORAGE: WamoID => (value)
    ////////////////////////////////////////////////////////*/
    mapping(uint256 => uint8[]) attributes;
    mapping(uint256 => Ability[]) abilities;

    constructor(uint64 subscriptionId)
        ERC721(NAME, SYMBOL)
        ConfirmedOwner(msg.sender)
    {}

    // TODO
    function mint() public returns (uint256) {}
}
