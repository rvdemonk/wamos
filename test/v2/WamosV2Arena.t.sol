// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "~/test/VRFCoordinatorV2Mock.sol";
import "~/v2/WamosV2.sol";
import "~/v2/WamosV2Arena.sol";
import "./WamosV2TestHelper.sol";

contract WamosV2Test is Test, WamosV2TestHelper {
    WamosV2 wamos;
    WamosV2Arena arena;
    VRFCoordinatorV2Mock vrfCoordinator;

    // VRF COORD
    uint64 subscriptionId;
    uint256[] requestIds;

    function setUp() public {}
}