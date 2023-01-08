// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

enum DamageType {
    MEELEE,
    MAGIC,
    RANGE
}

struct Ability {
    uint256 dietyType;
    DamageType damageType;
    uint256 power;
    uint256 accuracy;
    int16 range;
    uint256 cost;
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
    uint256 health;
    uint256 meeleeAttack;
    uint256 meeleeDefence;
    uint256 magicAttack;
    uint256 magicDefence;
    uint256 luck;
    uint256 stamina;
    uint256 mana;
    // special
    uint256 diety;
    uint256 manaRegen;
    uint256 staminaRegen;
    uint256 fecundity;
}

struct ArenaRecord {
    uint256 wins;
    uint256 losses;
}

contract WamosV2 is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public constant NAME = "WamosV2";
    string public constant SYMBOL = "WAMOS";

    //// WAMO CONSTANTS
    uint256 public constant NUMBER_OF_GODS = 8;
    uint256 public constant MAX_FECUNDITY = 16;
    uint256 public constant MAX_ABILITIES = 4;
    int16 public constant MAX_INDEX_MUTATION = 64;

    //// VRF COORDINATOR
    VRFCoordinatorV2Interface public vrfCoordinator;

    //// CONTRACT DATA
    uint256 public timestamp;
    address public contractOwner;
    uint256 public mintPrice;
    uint256 public nextWamoId;

    //// VRF CONFIG
    bytes32 public vrfKeyHash;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;
    uint16 public vrfRequestConfirmations;

    //// ARENA CONFIG
    address public arenaAddress;

    //// WAMO SPAWN DATA
    uint256[] public requestIds;
    uint256 public lastRequestId;
    mapping(uint256 => Request) requestIdToRequest;
    mapping(uint256 => uint256) wamoIdToRequestId;

    //// WAMO DATA
    mapping(uint256 => string) wamoIdToName;
    mapping(uint256 => ArenaRecord) wamoIdToRecord;
    // traits
    mapping(uint256 => int256) wamoIdToTraits;
    // movements
    mapping(uint256 => int16[8]) wamoIdToMovements;
    // abilities
    // mapping(uint256 => uint256[]) wamoIdToAbilities;
    mapping(uint256 => Ability[]) wamoIdToAbilities;

    //// EVENTS
    event SpawnRequested(
        address sender,
        uint256 requestId,
        uint256 startWamoId,
        uint256 numWamos
    );
    event SpawnCompleted(
        address sender,
        uint256 requestId,
        uint256 firstWamoId,
        uint256 lastWamoId
    );
    event ArenaStakingApproved(bool arenaStakingStatus);

    //// TEST EVENTS
    event GaussianRNGOutput(int256[] results);

    constructor(
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId,
        uint256 _mintPrice
    ) ERC721(NAME, SYMBOL) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        contractOwner = msg.sender;
        mintPrice = _mintPrice;
        nextWamoId = 1;
        timestamp = block.timestamp;
        // vrf setup
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

    /////////////////////////////////////////////////////////////////
    ////////////////////      WAMO SPAWNING      ////////////////////
    /////////////////////////////////////////////////////////////////

    function requestSpawn(
        uint32 number
    ) external payable returns (uint256 requestId) {
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

        for (uint256 i = 0; i < numToMint; i++) {
            _safeMint(owner, startingId + i);
        }
    }

    function completeSpawn(uint256 requestId) external {
        Request memory request = requestIdToRequest[requestId];
        require(request.exists, "Request does not exist");
        require(request.isFulfilled, "Randomness has not been fulfilled yet.");
        require(
            !request.isCompleted,
            "Spawn of this Wamo is already completed."
        );

        uint256 firstWamoId = request.firstWamoId;
        uint256 numWamos = request.numWamos;
        for (uint i = 0; i < numWamos; i++) {
            uint256 wamoId = firstWamoId + i;
            uint256 seed = request.seeds[i];
            generateTraits(wamoId, seed);
            generateMovements(wamoId, seed);
            generateAbilities(wamoId, seed);
        }
        requestIdToRequest[requestId].isCompleted = true;
        emit SpawnCompleted(
            request.sender,
            requestId,
            firstWamoId,
            firstWamoId + numWamos - 1
        );
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     WAMO GENERATION     ////////////////////
    /////////////////////////////////////////////////////////////////

    function generateTraits(uint256 wamoId, uint256 seed) internal {
        int256 encodedTraits;
        // number of [0,256] traits: 8
        // special traits: 3
        uint256 n = 12;
        int256 mu = 128;
        uint256 sigma = 32;
        // generate GRVs
        int256[] memory gaussianRVs = gaussianRNG(seed, n, mu, sigma);
        for (uint256 i = 0; i < n; i++) {
            encodedTraits |= (gaussianRVs[i] + 1) << (i * 8);
        }
        wamoIdToTraits[wamoId] = encodedTraits;
    }

    /**
     * @dev sample abilities for testing
     * todo
     */
    function generateAbilities(uint256 wamoId, uint256 seed) internal {
        Ability[4] memory abilities;
        // @dev two meelee attacks, two magic attacks
        for (uint256 i = 0; i < 2; i++) {
            wamoIdToAbilities[wamoId].push(
                Ability({
                    dietyType: seed % NUMBER_OF_GODS,
                    damageType: DamageType.MEELEE,
                    power: 60,
                    accuracy: 60,
                    range: 2,
                    cost: 10
                })
            );
        }
        for (uint256 i = 0; i < 2; i++) {
            wamoIdToAbilities[wamoId].push(
                Ability({
                    dietyType: seed % NUMBER_OF_GODS,
                    damageType: DamageType.MAGIC,
                    power: 60,
                    accuracy: 60,
                    range: 5,
                    cost: 10
                })
            );
        }
    }

    /**
     * @dev kingmove r=1 and r=3 for testing
     * todo
     */
    function generateMovements(uint256 wamoId, uint256 seed) internal {
        // test moves
        int16[8] memory moves = [int16(-1), 1, -16, 16, 3, -3, 48, -48];
        wamoIdToMovements[wamoId] = moves;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     VIEW FUNCTIONS      ////////////////////
    /////////////////////////////////////////////////////////////////

    function getAbilities(
        uint256 wamoId
    ) public view returns (Ability[] memory abilities) {
        abilities = wamoIdToAbilities[wamoId];
    }

    function getAbility(
        uint256 wamoId, uint256 index
    ) public view returns (Ability memory ability) {
        // todo error if index > 3
        ability = wamoIdToAbilities[wamoId][index];
    }

    function getMovements(
        uint256 wamoId
    ) public view returns (int16[8] memory movements) {
        movements = wamoIdToMovements[wamoId];
    }

    function getMovement(
        uint256 wamoId, uint256 index
    ) public view returns (int16 movement) {
        // todo error if index > 7
        movement = wamoIdToMovements[wamoId][index];
    }

    function getTraits(
        uint256 wamoId
    ) public view returns (Traits memory traits) {
        int256 encodedTraits = wamoIdToTraits[wamoId];
        traits.health = uint256(uint8(int8(encodedTraits >> 8)));
        traits.meeleeAttack = uint256(uint8(int8(encodedTraits >> 16)));
        traits.meeleeDefence = uint256(uint8(int8(encodedTraits >> 24)));
        traits.magicAttack = uint256(uint8(int8(encodedTraits >> 32)));
        traits.magicDefence = uint256(uint8(int8(encodedTraits >> 40)));
        traits.luck = uint256(uint8(int8(encodedTraits >> 48)));
        traits.stamina = uint256(uint8(int8(encodedTraits >> 56)));
        traits.mana = uint256(uint8(int8(encodedTraits >> 64)));
        // special
        traits.diety =
            uint256(uint8(int8(encodedTraits >> 72))) %
            NUMBER_OF_GODS;
        traits.manaRegen =
            uint256(uint8(int8(encodedTraits >> 80))) %
            traits.mana;
        traits.staminaRegen =
            uint256(uint8(int8(encodedTraits >> 88))) %
            traits.stamina;
        traits.fecundity =
            uint256(uint8(int8(encodedTraits >> 96))) %
            MAX_FECUNDITY;
        return traits;
    }

    // split get request data functions for smart contract use
    function getRequestStatus(
        uint256 requestId
    ) public view returns (bool fulfilled, bool completed) {
        fulfilled = requestIdToRequest[requestId].isFulfilled;
        completed = requestIdToRequest[requestId].isCompleted;
    }

    function getRequestData(
        uint256 requestId
    )
        public
        view
        returns (address sender, uint256 firstWamoId, uint256 numWamos)
    {
        sender = requestIdToRequest[requestId].sender;
        firstWamoId = requestIdToRequest[requestId].firstWamoId;
        numWamos = requestIdToRequest[requestId].numWamos;
    }

    // single request view function for external use
    function getRequest(
        uint256 requestId
    )
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

    /////////////////////////////////////////////////////////////////
    ////////////////////  VRF CONFIG FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function setVrfCallbackGasLimit(uint32 _gasLimit) public onlyOwner {
        vrfCallbackGasLimit = _gasLimit;
    }

    function setVrfRequestConfirmations(
        uint16 _numConfirmations
    ) public onlyOwner {
        vrfRequestConfirmations = _numConfirmations;
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
    /////////////////    ARENA STAKING FUNCTIONS   //////////////////
    /////////////////////////////////////////////////////////////////

    function setWamosArenaAddress(address _arenaAddress) external onlyOwner {
        arenaAddress = _arenaAddress;
    }

    function approveArenaStaking(bool arenaStakingStatus) public {
        require(arenaAddress != address(0), "Wamos Arena Address is not set!");
        // sets approval for msg.sender
        super.setApprovalForAll(arenaAddress, arenaStakingStatus);
        emit ArenaStakingApproved(arenaStakingStatus);
    }

    /////////////////////////////////////////////////////////////////
    /////////////////       SETTER FUNCTIONS       //////////////////
    /////////////////////////////////////////////////////////////////

    function setWamoName(
        uint256 wamoId,
        string memory name
    ) public onlyWamoOwner(wamoId) {
        wamoIdToName[wamoId] = name;
    }

    function recordWin(uint256 wamoId) external onlyArena {
        wamoIdToRecord[wamoId].wins++;
    }

    function recordLoss(uint256 wamoId) external onlyArena {
        wamoIdToRecord[wamoId].losses++;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////      LIBRARY FUNCTIONS       //////////////////
    /////////////////////////////////////////////////////////////////

    function gaussianRNG(
        uint256 seed,
        uint256 n,
        int256 mu,
        uint256 sigma
    ) public returns (int256[] memory) {
        uint256 _num = uint256(keccak256(abi.encodePacked(seed)));
        int256[] memory results_array = new int256[](n);
        uint256 gaussianRV;
        for (uint256 i = 0; i < n; i++) {
            // count 1s for gaussian random variable
            gaussianRV = countOnes(_num);
            // transform and store
            results_array[i] =
                int256((int(gaussianRV) * int(sigma)) / 8) -
                (128 * int(sigma)) /
                8 +
                mu;
            _num = uint256(keccak256(abi.encodePacked(_num)));
        }
        // event for testing
        emit GaussianRNGOutput(results_array);
        return results_array;
    }

    function countOnes(uint256 n) private pure returns (uint256 count) {
        // prettier-ignore
        assembly {
            for {} gt(n, 0) {} {
                n := and(n, sub(n, 1))
                count := add(count, 1)
            }
        }
    }
}
