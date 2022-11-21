// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";

struct Request {
    bool exists;
    bool fulfilled;
    bool compeleted;
    address sender;
    uint256 word;
    uint256 wamoId;
}

struct Traits {
    uint256 wamoId;
}

struct Ability {
    uint256 abilityId;
}

struct BattleRecord {
    uint256 wins;
    uint256 losses;
}

contract Wamos is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public constant NAME = "WamosV2";
    string public constant SYMBOL = "WAMOS";

    //// VRF COORDINATOR
    VRFCoordinatorV2Interface public vrfCoordinator;

    //// CONTRACT DATA
    address public contractOwner;
    uint256 public tokenCount;
    uint256 public mintPrice;

    //// VRF CONFIG
    bytes32 public vrfKeyHash;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;
    uint16 public vrfRequestConfirmations;

    //// ARENA CONFIG
    address arenaAddress;

    //// WAMO SPAWN DATA
    mapping(uint256 => Request) tokenIdToRequest;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    //// WAMO DATA
    // trait mapping
    // ability mapping
    // name mapping

    constructor(
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId,
        uint256 _mintPrice
    ) ERC721(NAME, SYMBOL) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        contractOwner = msg.sender;
        mintPrice = _mintPrice;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfRequestConfirmations = 3;
        vrfCallbackGasLimit = 200000;
    }

    //// MODIFIERS ////

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call.");
        _;
    }

    modifier onlyWamoOwner(uint256 wamoId) {
        require(
            msg.sender == ownerOf(wamoId),
            "Only the owner of this wamo can call"
        );
        _;
    }

    modifier onlyBattle() {
        require(
            msg.sender == arenaAddress,
            "Only WamosBattle can call this function."
        );
        _;
    }  

    //// SPAWNING ////

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}

    function requestSpawn() external payable {}
    function completeSpawn() external {}
    function _generateTraits() internal {}
    function _generateAbilities() internal {}

    //// VIEWS ////

    //// MINT CONFIG ////

    //// ARENA CONFIG ////


}