// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/ConfirmedOwner.sol";
import "./WamosRandomnessV0.sol";

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

 Wamo attributes = [ health, attack, defence, magic attack, magic defence, mana, stamina, luck ]
 */

enum Type {
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

struct WamoAttributes {
    uint8 Health;
    uint8 Attack;
    uint8 Defence;
    uint8 MagicAttack;
    uint8 MagicDefence;
    uint8 Stamina;
    uint8 Mana;
    uint8 Luck
}


contract WamosTokenV0 is ERC721, ConfirmedOwner {
    //// META CONSTANTS
    string public NAME = "WamosTokenV0";
    string public SYMBOL = "WAMOSV0";

    //// RANDOMNESS INSTANCE
    WamosRandomnessV0 Randomness;

    //// Mapping from wamo ID to array of wamo attributes
    // mapping(uint256 => uint8[]) attributes;
    mapping(uint256 => WamoAttributes[])
    // Mappping from wamo ID to array of the wamos abilities
    mapping(uint256 => Ability[]) abilities;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    constructor(uint64 subscriptionId)
        ERC721(NAME, SYMBOL)
        ConfirmedOwner(msg.sender)
    {}

    // TODO
    function mint() public returns (uint256) {
        // call randomness
        // init new wamo
        // generate attributes
        // pack struct
        // push wamo to
    }
}
