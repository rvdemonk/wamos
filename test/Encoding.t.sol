// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";

contract EncodingTest is Test {

    uint256 seed = 72984518589826227531578991903372844090998219903258077796093728159832249402700;

    function testEncoding1() public {
        console.log(seed);
        for (uint i=2; i<16; i=i+2) {
            console.log(uint8(seed>>i));
        }
    }
}