// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "lib/OnChainRNG/GaussianRNG/contracts/GaussianRNG.sol";

contract GaussianRNGTest is Test {

    uint256 seed = 78541660797044910968829902406342334108369226379826116161446442989268089806461;

    GaussianRNG rng;

    function setUp() public {
        rng = new GaussianRNG();
    }

    function testOutput() public {
        uint256 n = 16;
        int256[] memory randoms = rng.reproduceGaussianRandomNumbers(seed, n);
        console.logInt(randoms[0]);
        console.logInt(randoms[1]);
        console.logInt(randoms[2]);
        console.logInt(randoms[3]);
        console.logInt(randoms[4]);
    }
}