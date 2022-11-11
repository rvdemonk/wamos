// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
// import "solmate/tokens/ERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "src/v1/lib/WamosMathV1.sol";

// struct Ability {
//     uint256 Type;
//     uint256 attack;
//     uint256 defence;
//     uint256 magicAttack;
//     uint256 magicDefence;
//     uint256 speed;
//     uint256 accuracy;
//     uint256 manaCost;
//     uint256 staminaCost;
//     uint256 healthCost;
//     uint256 cooldown;
// }

struct Ability {
    uint256 dietyType;
    uint256 effectType;
    uint256 targetTrait;
    uint256 power;
    uint256 accuracy;
    uint256 cost;
    uint256 cooldown;
}

struct WamoTraits {
    int16[8] movements;
    uint256 health;
    uint256 attack;
    uint256 defence;
    uint256 magicAttack;
    uint256 magicDefence;
    uint256 stamina;
    uint256 mana;
    uint256 luck;
    uint256 fecundity;
    uint256 gearSlots;
}

struct SpawnRequest {
    bool exists;
    bool randomnessFulfilled;
    bool completed;
    uint256 randomWord;
    address sender;
    uint256 tokenId;
}

error SpawnRequestNotFound(uint256 requestId);
error SpawnRequestNotFulfilled(uint256 requestId);
error WamoAlreadySpawned(uint256 tokenId);

contract WamosV1 is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public NAME = "WamosTokenV1";
    string public SYMBOL = "WAMOSV1";

    address public contractOwner;
    uint256 public tokenCount;
    uint256 public mintPrice;

    // VRF COORDINATOR
    VRFCoordinatorV2Interface vrfCoordinator;

    // VRF CONFIGURATION
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    // WAMO SPAWN REQUEST STORAGE
    mapping(uint256 => SpawnRequest) requestIdToSpawnRequest;
    mapping(uint256 => uint256) requestIdToTokenId;
    mapping(uint256 => uint256) tokenIdToRandomnWord;
    mapping(uint256 => uint256) tokenIdToSpawnRequest;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // WAMO DATA
    mapping(uint256 => WamoTraits) wamoIdToTraits;
    mapping(uint256 => Ability[]) wamoIdToAbilities;

    // EVENTS
    event SpawnRequested(
        uint256 requestId,
        uint256 indexed tokenId,
        address sender
    );
    event SpawnCompleted(
        uint256 requestId,
        uint256 indexed tokenId,
        address owner
    );
    event RandomnessFulfilled(uint256 requestId, uint256 tokenId);

    constructor(
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId,
        uint256 _mintPrice
    ) ERC721(NAME, SYMBOL) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        // configure contract
        contractOwner = msg.sender;
        mintPrice = _mintPrice;
        // instantiate vrf coordinator
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        // configure coordinator variables
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfNumWords = 1;
        vrfCallbackGasLimit = 100000;
        vrfRequestConfirmations = 2;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call.");
        _;
    }

    /**
     * @notice Stage 1 of wamo mint
     * Wamo request is made, VRF request sent, request stored, event emitted
     * @custom:decision return request id or token id? does this matter with two-way mapping?
     */
    function requestSpawnWamo() public payable returns (uint256 requestId) {
        require(msg.value >= mintPrice, "Insufficient payment to mint Wam0.");
        // assign token id for new wamo
        uint256 tokenId = tokenCount;
        tokenCount++;
        // request randomness (from the gods)
        requestId = vrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            vrfRequestConfirmations,
            vrfCallbackGasLimit,
            vrfNumWords
        );
        // store request, including token id of requested wamo
        requestIdToSpawnRequest[requestId] = SpawnRequest({
            exists: true,
            randomnessFulfilled: false,
            completed: false,
            randomWord: 0,
            sender: msg.sender,
            tokenId: tokenId
        });
        tokenIdToSpawnRequest[tokenId] = requestId;
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit SpawnRequested(requestId, tokenId, msg.sender);
        return requestId;
    }

    /**
     * @notice Stage 2 of wamo mint
     * @param tokenId the id of the token requested for which to generate traits and mint to request sender
     */
    function completeSpawnWamo(uint256 tokenId) public payable {
        require(tokenCount > tokenId, "This token id has not been minted yet!");
        uint256 requestId = tokenIdToSpawnRequest[tokenId];
        // check request has not already been fulfilled
        if (requestIdToSpawnRequest[requestId].completed) {
            revert WamoAlreadySpawned(tokenId);
        }
        // check vrf request fulfilled
        if (!requestIdToSpawnRequest[requestId].randomnessFulfilled) {
            revert SpawnRequestNotFulfilled(requestId);
        }
        // retrieve randomness
        uint256 randomWord = requestIdToSpawnRequest[requestId].randomWord;
        // generator traits and abilities with randomness
        wamoIdToTraits[tokenId] = _generateWamoTraits(randomWord);
        address owner = requestIdToSpawnRequest[requestId].sender;
        // _safeMint(owner, tokenId);
        emit SpawnCompleted(requestId, tokenId, owner);
    }

    /**
     * @dev public visibility for testing and experimenting
     * TODO make less shit
     */
    function _generateWamoTraits(uint256 randomWord)
        public
        pure
        returns (WamoTraits memory traits)
    {
        // hardcoded king movement for testing
        traits.movements = [int16(-1), 1, 15, 16, 17, -15, -16, -17];
        {        
            (
                uint256 a,
                uint256 b,
                uint256 c,
                uint256 d,
                uint256 e
            ) = splitFirstFiveIntegers(randomWord, 100); 
            traits.health = a;
            traits.attack = b;
            traits.defence = c;
            traits.magicAttack = d;
            traits.magicDefence = e;
        }
                {        
            (
                uint256 f,
                uint256 g,
                uint256 h,
                uint256 i,
                uint256 j
            ) = splitSecondFiveIntegers(randomWord, 100); 
            traits.stamina = f;
            traits.mana = g;
            traits.luck = h;
        }
            traits.fecundity = randomWord % 11;   
            traits.gearSlots = randomWord % 4;
        return traits;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     VIEW FUNCTIONS      ////////////////////
    /////////////////////////////////////////////////////////////////

    function getSpawnRequest(uint256 requestId)
        public
        view
        returns (SpawnRequest memory request)
    {
        request = requestIdToSpawnRequest[requestId];
        return request;
    }

    // Has the randomness request for requestId been fulfilled?
    function getSpawnRequestStatus(uint256 requestId)
        public
        view
        returns (bool requestIsFulfilled)
    {
        SpawnRequest memory request = requestIdToSpawnRequest[requestId];
        requestIsFulfilled = request.randomnessFulfilled;
        return requestIsFulfilled;
    }

    function getTokenIdFromRequestId(uint256 requestId)
        public
        view
        returns (uint256 tokenId)
    {
        tokenId = requestIdToTokenId[requestId];
        return tokenId;
    }

    function getRequestCount() public view returns (uint256 count) {
        count = requestIds.length;
        return count;
    }

    function getWamoTraits(uint256 tokenId)
        public
        view
        returns (WamoTraits memory traits)
    {
        traits = wamoIdToTraits[tokenId];
        return traits;
    }

    function getWamoMovements(uint256 tokenId)
        public
        view
        returns (int16[8] memory)
    {
        return wamoIdToTraits[tokenId].movements;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////     META MINT FUNCTIONS      //////////////////
    /////////////////////////////////////////////////////////////////

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function withdrawFunds() public payable onlyOwner {
        payable(contractOwner).transfer(address(this).balance);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // check request exists
        if (!requestIdToSpawnRequest[_requestId].exists) {
            revert SpawnRequestNotFound(_requestId);
        }
        requestIdToSpawnRequest[_requestId].randomnessFulfilled = true;
        requestIdToSpawnRequest[_requestId].randomWord = _randomWords[0];
        uint256 tokenId = requestIdToSpawnRequest[_requestId].tokenId;
        address owner = requestIdToSpawnRequest[_requestId].sender;
        _safeMint(owner, tokenId);
        emit RandomnessFulfilled(_requestId, tokenId);
    }

    /** @dev only for solmate erc721 */
    // function tokenURI(uint256 id) public pure override returns (string memory) {
    //     return Strings.toString(id);
    // }

    /** LIBRARY FUNCTIONS */

    function splitFirstFiveIntegers(uint256 x, uint256 base)
        internal
        pure
        returns (
            uint256 a,
            uint256 b,
            uint256 c,
            uint256 d,
            uint256 e
        )
    {
        a = x % base;
        b = (x / 10) % base;
        c = (x / 100) % base;
        d = (x / 1000) % base;
        e = (x / 10000) % base;
        return (a, b, c, d, e);
    }

    function splitSecondFiveIntegers(uint256 x, uint256 base)
        internal
        pure
        returns (
            uint256 a,
            uint256 b,
            uint256 c,
            uint256 d,
            uint256 e
        )
        {
        a = (x / 100000) % base;
        b = (x / 1000000) % base;
        c = (x / 10000000) % base;
        d = (x / 100000000) % base;
        e = (x / 1000000000) % base;
        return (a, b, c, d, e);
        }
}
