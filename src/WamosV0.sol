// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

// import "openzeppelin/token/ERC721/ERC721.sol";
import "solmate/tokens/ERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "./WamosRandomnessV0.sol";
import "./interfaces/WamosRandomnessV0Interface.sol";
import "openzeppelin/utils/Strings.sol";

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

error RandomnessRequestFailed(uint256 requestId);

contract WamosV0 is ERC721 {
    //// META CONSTANTS
    string public NAME = "WamosTokenV0";
    string public SYMBOL = "WAMOSV0";
    uint256 public tokenCount;

    address public owner;

    //// RANDOMNESS INSTANCE
    WamosRandomnessV0Interface Randomness;

    //// Mapping from wamo ID to array of wamo attributes
    // mapping(uint256 => uint8[]) attributes;
    WamoData[] public attributes;
    uint256[] public randomWords;
    // Mappping from wamo ID to array of the wamos abilities
    mapping(uint256 => Ability[]) abilities;

    constructor(address randomnessAddr) ERC721(NAME, SYMBOL) {
        owner = msg.sender;
        Randomness = WamosRandomnessV0Interface(randomnessAddr);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call.");
        _;
    }

    function setRandomness(address randomnessAddr) external onlyOwner {
        Randomness = WamosRandomnessV0Interface(randomnessAddr);
    }

    // TODO
    function spawn() external payable returns (uint256 newWamoId) {
        uint256 newWamoId = tokenCount;
        tokenCount++;
        // call randomness
        uint256 randWord = getRandomness();
        randomWords.push(randWord);
        // init new wamo
        // WamoData storage wamo = attributes.push();
        // wamo.id = tokenCount;
        // erc721 mint
        // _safeMint(msg.sender, tokenCount);
        // generate attributes
        // pack struct
        // push wamo to
        return newWamoId;
    }

    function testFunction() public payable returns (bool success) {
        return true;
    }

    function tokenURI(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return Strings.toString(id);
    }

    function getRandomness() private view returns (uint256 randomWord) {
        uint256 requestId = Randomness.requestRandomWords();
        (bool isFulfilled, uint256[] memory _randomWords) = Randomness
            .getRequestStatus(requestId);
        if (!isFulfilled) {
            revert RandomnessRequestFailed(requestId);
        }
        return _randomWords[0];
    }
}
