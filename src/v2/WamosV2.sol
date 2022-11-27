// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";


enum DamageType {
    MEELEE,
    MAGIC,
    RANGE
}

struct Request {
    bool exists;
    bool isFulfilled;
    bool isCompleted;
    address sender;
    uint256 requestId;
    uint256 firstWamoId;
    uint256 numWamos;
    uint256[] seeds;
}

struct Traits {
    uint256 seed;
    int16[8] movements;
    uint256 diety;
    uint256 health;
    uint256 meeleeAttack;
    uint256 meeleeDefence;
    uint256 magicAttack;
    uint256 magicDefence;
    uint256 luck;
    uint256 stamina;
    uint256 mana;
    uint256 regen;
    uint256 fecundity;
}

struct Ability {
    uint256 abilityId;
}

struct ArenaRecord {
    uint256 wins;
    uint256 losses;
}

contract WamosV2 is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public constant NAME = "WamosV2";
    string public constant SYMBOL = "WAMOS";

    //// VRF COORDINATOR
    VRFCoordinatorV2Interface public vrfCoordinator;

    //// CONTRACT DATA
    address public contractOwner;
    uint256 public mintPrice;
    uint256 public nextWamoId;

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

    //// WAMO DATA
    mapping(uint256 => string) wamoIdToName;
    mapping(uint256 => ArenaRecord) wamoIdToRecord;
    // traits
    mapping(uint256 => uint256) wamoIdToTraits;
    // movements
    mapping(uint256 => int16[8]) wamoIdToMovements;
    // abilities
    mapping(uint256 => uint256[]) wamoIdToAbilities;


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
        nextWamoId = 1;

        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfRequestConfirmations = 3;
        vrfCallbackGasLimit = 500000;
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
            isFulfilled: false,
            isCompleted: false,
            sender: msg.sender,
            requestId: requestId,
            firstWamoId: startWamoId,
            numWamos: number,
            seeds: new uint256[](number)
        });
        emit SpawnRequested(msg.sender, requestId, startWamoId, number);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // store request data
        requestIdToRequest[_requestId].isFulfilled = true;
        requestIdToRequest[_requestId].seeds = _randomWords;
        // mint erc721 tokens
        address owner = requestIdToRequest[_requestId].sender;
        uint256 startingId = requestIdToRequest[_requestId].firstWamoId;
        uint256 numToMint = requestIdToRequest[_requestId].numWamos;
        for (uint256 i=0; i<numToMint; i++) {
            _safeMint(
                owner,
                startingId + i
            );
        }
    }

    function completeSpawn(uint256 requestId) external {
        Request memory request = requestIdToRequest[requestId];
        require(request.exists, "Request does not exist");
        require(request.isFulfilled, "Randomness has not been fulfilled yet.");
        require(!request.isCompleted, "Spawn of this Wamo is already completed.");
        uint256 firstWamoId = request.firstWamoId;
        for (uint i=0; i < request.numWamos; i++) {
            uint256 seed = request.seeds[i];
            // generateAbilities(firstWamoId + i, seed);
            // generateTraits(firstWamoId + i, seed);
            // Traits memory traits;
            // traits.seed = seed;
            // wamoIdToTraits[firstWamoId+i] = traits;
        }
        requestIdToRequest[requestId].isCompleted = true;
        emit SpawnCompleted(request.sender, requestId);
    }   


    function generateTraits(uint256 wamoId, uint256 seed) internal {}

    function generateAbilities(uint256 wamoId, uint256 seed) internal {}

    //// VIEWS ////

    function getRequestStatus(uint256 requestId) public view returns (bool fulfilled, bool completed) {
        fulfilled = requestIdToRequest[requestId].isFulfilled;
        completed = requestIdToRequest[requestId].isCompleted;
    }

    function getRequestData(uint256 requestId) 
        public 
        view
        returns (
            address sender,
            uint256 firstWamoId,
            uint256 numWamos
        )
        {
            sender = requestIdToRequest[requestId].sender;
            firstWamoId = requestIdToRequest[requestId].firstWamoId;
            numWamos = requestIdToRequest[requestId].numWamos;
        }
    

    // TODO cull request viewing functions; 
    //  i) return entire request, such as here, or
    //  ii) split view into two functions, as above
    function getRequest(uint256 requestId)
        public
        view
        returns (
            bool exists,
            bool isFulfilled,
            bool isCompleted,
            address sender,
            uint256 firstWamoId,
            uint256 numWamos,
            uint256[] memory seeds
        )
        {
            exists = requestIdToRequest[requestId].exists;
            isFulfilled = requestIdToRequest[requestId].isFulfilled;
            isCompleted = requestIdToRequest[requestId].isCompleted;
            sender = requestIdToRequest[requestId].sender;
            firstWamoId = requestIdToRequest[requestId].firstWamoId;
            numWamos = requestIdToRequest[requestId].numWamos;
            seeds = requestIdToRequest[requestId].seeds;
        }
    
    //// VRF CONFIG ////

    function setVrfCallbackGasLimit(uint32 _gasLimit) public onlyOwner {
        vrfCallbackGasLimit = _gasLimit;
    }

    function setVrfRequestConfirmations(uint16 _numConfirmations) public onlyOwner {
        vrfRequestConfirmations = _numConfirmations;
    }

    //// MINT CONFIG ////

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function withdrawFunds() public payable onlyOwner {
        payable(contractOwner).transfer(address(this).balance);
    }  

    //// ARENA CONFIG ////

    function setWamosArenaAddress(address _arenaAddress) external onlyOwner {
        arenaAddress = _arenaAddress;
    }

    function approveArenaStaking() public {
        // sets approval for msg.sender
        super.setApprovalForAll(arenaAddress, true);
    }

    //// SETTER FUNCTIONS ////

    function setWamoName(uint256 wamoId, string memory name) public onlyWamoOwner(wamoId) {
        wamoIdToName[wamoId] = name;
    }

    function recordWin(uint256 wamoId) external onlyArena {
        wamoIdToRecord[wamoId].wins++;
    }

    function recordLoss(uint256 wamoId) external onlyArena {
        wamoIdToRecord[wamoId].losses ++;
    }
}