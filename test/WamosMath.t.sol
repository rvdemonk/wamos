// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/lib/WamosMath.sol";

contract WamoMathTest is Test {
    uint256 word =
        78541660797044910968829902406342334108369226379826116161446442989268089806461;

    function setUp() public {}

    function testWordSplit() public {
        uint256 mod = 1000;
        (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e) = WamosMath
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
}
