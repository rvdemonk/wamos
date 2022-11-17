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

struct Ability {
    uint256 dietyType;
    DamageType damageType;
    // -> insert (de)buff effects
    uint256 power;
    uint256 accuracy;
    int16 range;
    uint256 cost;
}

struct WamoTraits {
    int16[8] movements;
    uint256 dietyType;
    uint256 health;
    uint256 meeleeAttack;
    uint256 meeleeDefence;
    uint256 rangeAttack;
    uint256 rangeDefence;
    uint256 magicAttack;
    uint256 magicDefence;
    uint256 stamina;
    uint256 mana;
    uint256 luck;
    uint256 fecundity;
    // uint256 gearSlots;
    uint256 energyRegen; // mana and stamina
    // recover (hp regen)
    // hp regen per turn
}

struct WamoRecord {
    uint256 wins;
    uint256 losses;
    uint256 draws;
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
    // TEST VARIABLES
    uint256 public requestCount;

    // META CONSTANTS
    string public constant NAME = "WamosTokenV1";
    string public constant SYMBOL = "WAMOSV1";

    // WAMO CONSTANTS
    uint256 public constant ABILITY_SLOTS = 4;
    uint256 public constant MOVE_CHOICE = 8;
    int16 public constant MAX_INDEX_MUATION = 48;

    // GAME CONSTANTS

    address public contractOwner;
    uint256 public tokenCount;
    uint256 public mintPrice;

    // VRF COORDINATOR
    VRFCoordinatorV2Interface public vrfCoordinator;

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
    mapping(uint256 => uint256) tokenIdToSpawnRequestId;
    mapping(uint256 => WamoRecord) tokenIdToRecord;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // WAMO DATA
    mapping(uint256 => WamoTraits) wamoIdToTraits;
    mapping(uint256 => Ability[]) wamoIdToAbilities;
    mapping(uint256 => string) wamoIdToWamoName;

    // WAMOS BATTLE ADDRESS
    address public wamosBattleAddr;

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
        vrfCallbackGasLimit = 200000;
        vrfRequestConfirmations = 3;
    }

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
            msg.sender == wamosBattleAddr,
            "Only WamosBattle can call this function."
        );
        _;
    }

    /**
     * @notice Stage 1 of wamo mint
     * Wamo request is made, VRF request sent, request stored, event emitted
     * @custom:decision return request id or token id? does this matter with two-way mapping?
     */
    function requestSpawnWamo() public payable returns (uint256 requestId) {
        require(msg.value >= mintPrice, "Insufficient payment to mint Wam0.");
        // request randomness (from the gods)
        requestId = vrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            vrfRequestConfirmations,
            vrfCallbackGasLimit,
            vrfNumWords
        );
        // store request
        requestIds.push(requestId);
        lastRequestId = requestId;
        requestCount++;
        // map to token id
        uint256 tokenId = tokenCount;
        tokenCount++;
        tokenIdToSpawnRequestId[tokenId] = requestId;
        requestIdToTokenId[requestId] = tokenId;
        // create request struct
        requestIdToSpawnRequest[requestId] = SpawnRequest({
            exists: true,
            randomnessFulfilled: false,
            completed: false,
            randomWord: 0,
            sender: msg.sender,
            tokenId: tokenId
        });
        emit SpawnRequested(requestId, tokenId, msg.sender);
        return requestId;
    }

    /**
     * @notice Stage 2 of wamo mint
     * @param tokenId the id of the token requested for which to generate traits and mint to request sender
     */
    function completeSpawnWamo(uint256 tokenId) public payable {
        require(
            tokenCount >= tokenId,
            "This token id has not been minted yet!"
        );
        uint256 requestId = tokenIdToSpawnRequestId[tokenId];
        if (requestIdToSpawnRequest[requestId].completed) {
            revert WamoAlreadySpawned(tokenId);
        }
        if (!requestIdToSpawnRequest[requestId].randomnessFulfilled) {
            revert SpawnRequestNotFulfilled(requestId);
        }

        uint256 randomWord = requestIdToSpawnRequest[requestId].randomWord;
        _generateWamoTraits(tokenId, randomWord);
        _generateAbilities(tokenId, randomWord);
        // toggle spawn request as complete
        requestIdToSpawnRequest[requestId].completed = true;
        // retrieve owner in case it is not msg.sender
        address owner = requestIdToSpawnRequest[requestId].sender;
        emit SpawnCompleted(requestId, tokenId, owner);
    }

    /**
     * @dev public visibility for testing and experimenting TODO change this
     * TODO make less shit
     */
    function _generateWamoTraits(uint256 tokenId, uint256 randomWord) internal {
        WamoTraits memory traits;
        // hardcoded king movement for testing
        // traits.movements = [int16(-1), 1, 15, 16, 17, -15, -16, -17];
        {
            (
                uint256 a,
                uint256 b,
                uint256 c,
                uint256 d,
                uint256 e
            ) = shaveOffRandomIntegers(randomWord, 2, 0);
            traits.health = a;
            traits.meeleeAttack = b;
            traits.meeleeDefence = c;
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
            ) = shaveOffRandomIntegers(randomWord, 2, 1);
            traits.stamina = f;
            traits.mana = g;
            traits.luck = h;
            traits.rangeAttack = i;
            traits.rangeDefence = j;
        }
        {
            (
                uint256 k,
                uint256 l,
                uint256 m,
                uint256 n,
                uint256 o
            ) = shaveOffRandomIntegers(randomWord, 2, 2);
            int16 move1 = int8(int256(k)) % MAX_INDEX_MUATION;
            int16 move2 = int8(int256(l)) % MAX_INDEX_MUATION;
            traits.movements = [
                int16(-1),
                1,
                16,
                -16,
                move1,
                -move1,
                move2,
                -move2
            ];
            traits.energyRegen = m % 23;
            traits.dietyType = n % 8;
        }
        traits.fecundity = randomWord % 11;
        // traits.gearSlots = randomWord % 4;
        // store traits
        wamoIdToTraits[tokenId] = traits;
    }

    function _generateAbilities(uint256 tokenId, uint256 randomWord) internal {
        for (uint256 i = 0; i < ABILITY_SLOTS; i++) {
            // word segment starts at 3 - first 3 used in trait gen
            Ability memory ability;
            uint256 wordSegmentNum = i + 2;
            (
                uint256 a,
                uint256 b,
                uint256 c,
                uint256 d,
                uint256 e
            ) = shaveOffRandomIntegers(randomWord, 3, wordSegmentNum);

            // determine move type
            if (a < 34) {
                ability.damageType = DamageType.MEELEE;
                ability.range = 1;
            } else if (a < 67) {
                ability.damageType = DamageType.MAGIC;
                ability.range = int16(uint16(d));
            } else {
                ability.damageType = DamageType.RANGE;
                ability.range = int16(uint16(d));
            }
            ability.power = b;
            ability.accuracy = c;
            ability.cost = e % 33;
            // store ability
            wamoIdToAbilities[tokenId].push(ability);
        }
    }

    /**
     * @dev Called by VRF Coordinator to fulfilled randomness
     */
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
        // MINT TO OWNER
        _safeMint(owner, tokenId);
        emit RandomnessFulfilled(_requestId, tokenId);
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     VIEW FUNCTIONS      ////////////////////
    /////////////////////////////////////////////////////////////////

    function getSpawnRequest(
        uint256 requestId
    ) public view returns (SpawnRequest memory request) {
        request = requestIdToSpawnRequest[requestId];
        return request;
    }

    // Has the randomness request for requestId been fulfilled?
    function getSpawnRequestStatus(
        uint256 requestId
    ) public view returns (bool requestIsFulfilled) {
        SpawnRequest memory request = requestIdToSpawnRequest[requestId];
        requestIsFulfilled = request.randomnessFulfilled;
        return requestIsFulfilled;
    }

    function getTokenIdFromRequestId(
        uint256 requestId
    ) public view returns (uint256 tokenId) {
        tokenId = requestIdToTokenId[requestId];
        return tokenId;
    }

    function getRequestCount() public view returns (uint256 count) {
        count = requestIds.length;
        return count;
    }

    function getWamoTraits(
        uint256 tokenId
    ) public view returns (WamoTraits memory traits) {
        traits = wamoIdToTraits[tokenId];
        return traits;
    }

    function getWamoAbilities(
        uint256 tokenId
    ) public view returns (Ability[] memory abilities) {
        return wamoIdToAbilities[tokenId];
    }

    function getWamoAbility(
        uint256 tokenId,
        uint256 index
    ) public view returns (Ability memory abilities) {
        require(
            index < ABILITY_SLOTS,
            "Ability index out of range (must be in [0,3])"
        );
        return wamoIdToAbilities[tokenId][index];
    }

    function getWamoMovements(
        uint256 tokenId
    ) public view returns (int16[8] memory) {
        return wamoIdToTraits[tokenId].movements;
    }

    function getWamoRecord(
        uint256 tokenId
    ) public view returns (WamoRecord memory record) {
        record = tokenIdToRecord[tokenId];
        return record;
    }

    function getWamoName(uint256 wamoId) public view returns (string memory) {
        return wamoIdToWamoName[wamoId];
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

    /////////////////////////////////////////////////////////////////
    ////////////////////  VRF CONFIG FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    // TODO at checks and require statements
    function setVrfCallbackGasLimit(uint32 _gasLimit) public onlyOwner {
        vrfCallbackGasLimit = _gasLimit;
    }

    function setVrfRequestConfirmations(
        uint16 _requestConfirmations
    ) public onlyOwner {
        vrfRequestConfirmations = _requestConfirmations;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////   BATTLE STAKING FUNCTIONS   //////////////////
    /////////////////////////////////////////////////////////////////

    function setWamosBattleAddress(
        address _wamosBattleAddr
    ) external onlyOwner {
        wamosBattleAddr = _wamosBattleAddr;
    }

    /**
     @notice Approves the wamos battle contract to transfer any token on 
        behalf of the CALLER
     @notice This function must be called by a player before they can connect their
        wamos and participate in battles
    */
    function approveBattleStaking() public {
        super.setApprovalForAll(wamosBattleAddr, true);
    }

    /////////////////////////////////////////////////////////////////
    /////////////////       SETTER FUNCTIONS       //////////////////
    /////////////////////////////////////////////////////////////////

    function setWamoName(
        uint256 wamoId,
        string memory name
    ) public onlyWamoOwner(wamoId) {
        wamoIdToWamoName[wamoId] = name;
    }

    function recordWin(uint256 wamoId) external onlyBattle {
        tokenIdToRecord[wamoId].wins++;
    }

    function recordLoss(uint256 wamoId) external onlyBattle {
        tokenIdToRecord[wamoId].losses++;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////      LIBRARY FUNCTIONS       //////////////////
    /////////////////////////////////////////////////////////////////

    // function abs(int8 number) public pure returns (int8) {
    //     return number >= 0 ? number : -number;
    // }

    /**
     * @notice internal library function to shave off random digits in sets of five from a 256bit randomWord
     * @param randomWord the random uint256 to be shaved
     * @param segmentNum \in [0, 10]; the set of five to be shaven: ie, 0-> first five, 1-> second five
     * @param shavingSize >0; size of numbers to be shaved off: 1 -> 1 digit numbers, 2 -> 2 digit numbers
     * @notice returns five single digit uint256
     */
    function shaveOffRandomIntegers(
        uint256 randomWord,
        uint256 shavingSize,
        uint256 segmentNum
    )
        public
        pure
        returns (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e)
    {
        uint256 base = 10 ** shavingSize;
        a = (randomWord / (1 ** shavingSize * 100_000 ** segmentNum)) % base;
        b = (randomWord / (10 ** shavingSize * 100_000 ** segmentNum)) % base;
        c = (randomWord / (100 ** shavingSize * 100_000 ** segmentNum)) % base;
        d = (randomWord / (1000 ** shavingSize * 100_000 ** segmentNum)) % base;
        e =
            (randomWord / (10000 ** shavingSize * 100_000 ** segmentNum)) %
            base;
        return (a, b, c, d, e);
    }
}
