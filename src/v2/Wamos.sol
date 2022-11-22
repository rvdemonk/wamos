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
    address sender;
    uint256 requestId;
    uint256 firstWamoId;
    uint256 numWamos;
    uint256[] randomWords;
}

struct Traits {
    uint256 wamoId;
    uint256 seed;
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
    uint256 public mintPrice;
    uint256 public nextWamoId = 1;

    //// VRF CONFIG
    bytes32 public vrfKeyHash;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;
    uint16 public vrfRequestConfirmations;

    //// ARENA CONFIG
    address arenaAddress;

    //// WAMO SPAWN DATA
    uint256[] public requestIds;
    uint256 public lastRequestId;
    mapping(uint256 => Request) requestIdToRequest;
    mapping(uint256 => uint256) wamoIdToRequestId;
    mapping(uint256 => Traits) wamoIdToTraits;

    //// WAMO DATA
    // trait mapping
    // ability mapping
    // name mapping

    //// EVENTS
    event SpawnRequested(address sender, uint256 requestId, uint256 startWamoId, uint256 numWamos);
    event SpawnCompleted(address sender, uint256 requestId);

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

    modifier onlyArena() {
        require(
            msg.sender == arenaAddress,
            "Only WamosBattle can call this function."
        );
        _;
    }  

    modifier onlyWamoOwner(uint256 wamoId) {
        require(
            msg.sender == ownerOf(wamoId),
            "Only the owner of this wamo can call"
        );
        _;
    }

    //// SPAWNING ////

    function requestSpawn(uint32 number) external payable returns (uint256 requestId) {
        require(msg.value >= mintPrice, "Insufficient msg.value to mint!");        
        requestId = vrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            vrfRequestConfirmations,
            vrfCallbackGasLimit,
            number
        );
        uint256 startWamoId = nextWamoId;
        nextWamoId += number;
        requestIdToRequest[requestId] = Request({
            exists: true,
            fulfilled: false,
            completed: false,
            sender: msg.sender,
            requestId: requestId,
            firstWamoId: startWamoId,
            numWamos: number,
            randomWords: new uint256[](number)
        });
        emit SpawnRequested(msg.sender, requestId, startWamoId, number);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        requestIdToRequest[_requestId].fulfilled = true;
        requestIdToRequest[_requestId].randomWords = _randomWords;
        address owner = requestIdToRequest[_requestId].sender;
        uint256 id = requestIdToRequest[_requestId].firstWamoId;
        uint256 idCap = id + requestIdToRequest[_requestId].numWamos;
        for (id; id < idCap; id++) {
            _safeMint(owner, id);

        }
    }

    function completeSpawn(uint256 requestId) external {
        Request memory request = requestIdToRequest[requestId];
        require(request.exists, "Request does not exist");
        require(request.completed, "Spawn of this Wamo has already completed.");
        require(request.fulfilled, "Randomness has not been fulfilled yet.");
        uint256 firstWamoId = request.firstWamoId;
        for (uint i=0; i < request.numWamos; i++) {
            uint256 seed = request.randomWords[i];
            // _generateAbilities(firstWamoId + i, seed);
            // _generateTraits(firstWamoId + i, seed);
        }
        emit SpawnCompleted(request.sender, requestId);
    }   


    // function _generateTraits(uint256 wamoId, uint256 seed) internal {}
    // function _generateAbilities(uint256 wamoId, uint256 seed) internal {}

    //// VIEWS ////

    //// MINT CONFIG ////

    //// ARENA CONFIG ////


}