// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";

contract EncodingTest is Test {
    struct testTraits {
        address owner;
        uint64 timeStamp;
        uint16 attack;
        uint16 defence;
        uint16 mana;
        uint16 stamina;
        uint16 luck;
    }

    uint256 seed =
        72984518589826227531578991903372844090998219903258077796093728159832249402700;
    address achilles = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;

    testTraits traits;
    uint256 encodedWamo;

    function setUp() public {
        uint64 time = uint64(block.timestamp);
        traits = testTraits({
            owner: achilles,
            timeStamp: time,
            attack: 100,
            defence: 50,
            mana: 200,
            stamina: 25,
            luck: 256
        });
    }

    function testEncoding1() public {
        console.log(seed);
        for (uint i = 2; i < 16; i = i + 2) {
            console.log(uint8(seed >> i));
        }
    }

    function testEncodedSeed() public {
        uint256 hashed = uint256(keccak256(abi.encodePacked(seed)));
        console.log(seed);
        console.log(hashed);
        uint256 hashedAgain = uint256(keccak256(abi.encodePacked(hashed)));
        console.log(hashedAgain);
    }

    function encodeWamo(testTraits memory _traits) private pure returns (uint256 wamo) {
        // wamo = uint256( _traits.owner);
        return wamo;
    }

    function testWamoEncoding() public {
        uint8 num = 170;
        uint256 fullNum = uint256(num);
        uint256 fullNumShifted = fullNum<<160;
        bytes memory encnum = abi.encodePacked(num);
        bytes memory encfullnum =  abi.encodePacked(fullNum);
        bytes memory encfullNumShifted = abi.encodePacked(fullNumShifted);
        console.logBytes(encnum);
        console.logBytes(encfullnum);
        console.logBytes(encfullNumShifted);
    }
}
