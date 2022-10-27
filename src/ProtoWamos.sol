// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";
import "chainlink/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink/VRFConsumerBaseV2.sol";
import "chainlink/ConfirmedOwner.sol";

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

/*
PROTOTYPE CONTRACT
CONTAINS HARDCODED VALUES
NOT FOR PRODUCTION USE!!
*/

contract ProtoWamos is ERC721, VRFConsumerBaseV2, ConfirmedOwner {
    //// META CONSTANTS
    string public NAME = "ProtoWAMOS";
    string public SYMBOL = "pWAMOs";

    //// VRF CONSUMER DATA STORAGE
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    /// VRF HARDCODED VARIABLES
    // gas limit; change depending on network and experimentation
    uint32 callbackGasLimit = 100000;
    // blocks to confirm; default is 3
    uint16 requestConfirmations;
    // number of values to retrieve in one request
    uint32 numWords = 2;

    // GAS LANES (governs max gas price)
    // goerli 150 gwei (only available)
    bytes32 GOERLI_KEYHASH =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    // mumbai 500 gwei (only available)
    bytes32 MUMBAI_KEYHASH =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    // fuji 300 gwei (only available)
    bytes32 FUJI_KEYHASH =
        0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    //// COORDINATERS
    // eth goerli testnet
    address GOERLI_COORDINATOR_ADDR =
        0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    // polygon mumbai testnet
    address MUMBAI_COORDINATOR_ADDR =
        0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    // avalanche fuji testnet
    address FUJI_COORDINATOR_ADDR = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    /* ////////////////////////////////////////////////////////
                WAMO DATA STORAGE: WamoID => (value)
    ////////////////////////////////////////////////////////*/
    mapping(uint256 => uint8[]) attributes;
    mapping(uint256 => Ability[]) abilities;

    constructor(uint64 subscriptionId)
        ERC721(NAME, SYMBOL)
        VRFConsumerBaseV2(MUMBAI_COORDINATOR_ADDR)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(MUMBAI_COORDINATOR_ADDR);
        s_subscriptionId = subscriptionId;
    }

    function mint() public returns (uint256) {}

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {}

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}
}
