// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../../src/v1/lib/WamosMathV1.sol";

contract WamosMathV1Test is Test {
    uint256 word =
        78541660797044910968829902406342334108369226379826116161446442989268089806461;

    uint256[] splitStore;

    function setUp() public {}

    /** @dev >1.5m gas for a word */
    function testSplitAllInplace() public {
        assertTrue(splitStore.length == 0);
        WamosMathV1.splitAllIntegers(word, 10, splitStore);
        assertTrue(splitStore.length > 0);
    }

    function testSplitFirstFive() public {
        uint256 mod = 100;
        (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = WamosMathV1
            .splitFirstFiveIntegers(word, mod);
        assertTrue(a + b + c + d + e < 5 * mod);
        console.log("random word:");
        console.log(word);
        console.log("after split:");
        console.log(a);
        console.log(b);
        console.log(c);
        console.log(d);
        console.log(e);
    }

    function testSplitSecondFive() public {
        uint256 mod = 100;
        (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = WamosMathV1
            .splitSecondFiveIntegers(word, mod);
        assertTrue(a + b + c + d + e < 5 * mod);
        console.log("random word:");
        console.log(word);
        console.log("after split:");
        console.log(a);
        console.log(b);
        console.log(c);
        console.log(d);
        console.log(e);
    }

    function testMathGasMultiply() public{
        uint256 number = 10 * 10 * 10 * 10;
    }

    function testMathGasExponent() public {
        uint256 number = 10**4;
    }

    function testMathGasBigExponent() public {
        uint256 number = 7 * 100_000**5;
    }
}