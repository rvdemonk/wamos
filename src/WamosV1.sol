// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

// import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
import "solmate/tokens/ERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./WamosRandomnessV0.sol";

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

struct WamoData {
    uint256 id;
    uint8 Health;
    uint8 Attack;
    uint8 Defence;
    uint8 MagicAttack;
    uint8 MagicDefence;
    uint8 Stamina;
    uint8 Mana;
    uint8 Luck;
}

struct SpawnRequest {
    bool exists;
    bool fulfilled;
    uint256 randomWord;
    address sender;
    uint256 tokenId;
}

error WamoSpawnRequestNotFound(uint256 requestId);

contract WamosV0 is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public NAME = "WamosTokenV0";
    string public SYMBOL = "WAMOSV0";

    address public contractOwner;
    uint256 public tokenCount;

    // VRF COORDINATOR
    VRFCoordinatorV2Interface vrfCoordinator;

    // VRF SETTINGS
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    // WAMO SPAWN REQUEST STORAGE
    mapping(uint256 => SpawnRequest) spawnRequests;
    uint256[] requestIds;
    uint256 lastRequestId;

    // WAMO DATA
    mapping(uint256 => WamoData[]) attributes;
    mapping(uint256 => Ability[]) abilities;

    constructor(
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) ERC721(NAME, SYMBOL) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        contractOwner = msg.sender;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
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
     * @dev First stage of mint
        Wamo request is made, VRF request sent, request stored, event emitted
     */
    function requestWamoSpawn() public payable returns (uint256 requestId) {
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
        // store request
        spawnRequests[requestId] = SpawnRequest({
            exists: true,
            fulfilled: false,
            randomWord: 0,
            sender: msg.sender,
            tokenId: tokenId
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        // TODO emit event
    }

    // TODO
    function claimRequestedWamo() public payable returns (uint256 tokenId) {
        // generate wamo traits
    }

    function withdrawFunds() public payable onlyOwner {
        payable(contractOwner).transfer(address(this).balance);
    } 

    function tokenURI(uint256 id) public view override returns (string memory) {
        return Strings.toString(id);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // check request exists
        if (!spawnRequests[_requestId].exists) {
            revert WamoSpawnRequestNotFound(_requestId);
        }
        spawnRequests[_requestId].fulfilled = true;
        spawnRequests[_requestId].randomWord = _randomWords[0];
        // TODO emit event
    }
}