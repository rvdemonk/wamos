// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

// import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/utils/Strings.sol";
import "solmate/tokens/ERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import "./interfaces/WamosRandomnessV0Interface.sol";
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
/**
    @dev Wamos must itself be a child of VRfConsumer, rather than simply instantiating
    an implemented vrf consumer to use, primarily for the purposes of testing,
    since the mock coordinator must be called to fulfill the request for
    randomness manually.

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

struct VRFRequest {
    bool exists;
    bool fulfilled;
    address sender;
    uint256 randomWord;
}

error VRFRequestNotFound(uint256 requestId);

contract WamosV0 is ERC721, VRFConsumerBaseV2 {
    //// META CONSTANTS
    string public NAME = "WamosTokenV0";
    string public SYMBOL = "WAMOSV0";

    address public owner;
    uint256 public tokenCount;

    // WAMO CHARACTERISTICS
    mapping(uint256 => WamoData[]) attributes;
    mapping(uint256 => Ability[]) abilities;

    // VRF CONSUMPTION
    mapping(uint256 => VRFRequest) vrfRequests;

    VRFCoordinatorV2Interface vrfCoordinator;

    uint256[] public vrfRequestIds;
    uint256 public lastVrfRequestId;
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    // EVENTS
    event RequestSent(uint256 indexed requestId);
    event RequestFulfilled(uint256 indexed requestId, uint256 randomWord);

    constructor(
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) ERC721(NAME, SYMBOL) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        owner = msg.sender;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;

        vrfNumWords = 1;
        vrfCallbackGasLimit = 200000;
        vrfRequestConfirmations = 2;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call.");
        _;
    }

    // TODO
    function spawn() external payable returns (uint256 newWamoId) {
        newWamoId = tokenCount;
        tokenCount++;
        return newWamoId;
    }

    function requestRandomWord() external returns (uint256 requestId) {
        // make vrf request
        requestId = vrfCoordinator.requestRandomWords(
            vrfKeyHash,
            vrfSubscriptionId,
            vrfRequestConfirmations,
            vrfCallbackGasLimit,
            vrfNumWords
        );
        // store request
        vrfRequests[requestId] = VRFRequest({
            exists: true,
            fulfilled: false,
            sender: msg.sender, // TODO always internal atm
            randomWord: 0
        });
        // store request id
        vrfRequestIds.push(requestId);
        lastVrfRequestId = requestId;
        // emit event
        // TODO
        return requestId;
    }

    function getVRFRequestStatus(
        uint256 _requestId
    ) public view returns (bool fulfilled, uint256 randomWord) {
        if (!vrfRequests[_requestId].exists) {
            revert VRFRequestNotFound(_requestId);
        }
        VRFRequest memory request = vrfRequests[_requestId];
        return (request.fulfilled, request.randomWord);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return Strings.toString(id);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // check request exists
        if (!vrfRequests[_requestId].exists) {
            revert VRFRequestNotFound(_requestId);
        }
        // toggle request fulfillment status
        vrfRequests[_requestId].fulfilled = true;
        // store randomness
        vrfRequests[_requestId].randomWord = _randomWords[0];
        // emit event
        // TODO
    }
}
