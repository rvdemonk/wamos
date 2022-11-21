// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";

struct Request {
    bool exists;
    bool fulfilled;
    bool completed;
    uint256 requestId;
    address sender;
    uint256 word;
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
    uint256 public wamoCount;
    uint256 public mintPrice;

    //// VRF CONFIG
    bytes32 public vrfKeyHash;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;
    uint16 public vrfRequestConfirmations;

    //// ARENA CONFIG
    address arenaAddress;

    //// WAMO SPAWN DATA
    mapping(uint256 => Request) wamoIdToRequest;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    //// WAMO DATA
    // trait mapping
    // ability mapping
    // name mapping

    //// EVENTS
    event SpawnRequested(address sender, uint256 wamoId, uint256 requestId);

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

    function requestSpawn() external payable returns (uint256 wamoId) {
        require( msg.value >= mintPrice, "Insufficient msg.value to mint!");
        wamoId = ++wamoCount; // wamoIds start at 1
        uint256 requestId = vrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            vrfRequestConfirmations,
            vrfCallbackGasLimit,
            1 // one word for spawn
        );
        wamoIdToRequest[wamoId] = Request({
            exists: true,
            fulfilled: false,
            completed: false,
            requestId: requestId,
            sender: msg.sender,
            word: 0
        });
        emit SpawnRequested(msg.sender, wamoId, requestId);
        return wamoId;
    }

    function completeSpawn(uint256 wamoId) external {
        require(wamoId <= wamoCount, "This Wamo has not yet been minted!");
        
        uint256 requestId = wamoIdToRequest[wamoId].requestId;
        
        require(!wamoIdToRequest[wamoId].completed, "Spawn of this Wamo has already completed.");
        // require()
    }   


    function _generateTraits() internal {}
    function _generateAbilities() internal {}

    //// VIEWS ////

    //// MINT CONFIG ////

    //// ARENA CONFIG ////


}