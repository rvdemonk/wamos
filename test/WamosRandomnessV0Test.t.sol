// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/WamosRandomnessV0.sol";
import "../src/test/LinkToken.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosRandomnessV0Test is Test {

    VRFCoordinatorV2Mock coordinator;
    LinkToken link;
    WamosRandomnessV0 randomness;

    function setUp() public {
        // deploy mocks
        coordinator = new VRFCoordinatorV2Mock();
        // deploy randomness
    }
}
