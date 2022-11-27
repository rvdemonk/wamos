// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "./WamosV2TestHelper.sol";
import "~/v2/WamosV2.sol";
import "~/test/VRFCoordinatorV2Mock.sol";

contract WamosV2Test is Test, WamosV2TestHelper {

    WamosV2 wamos;

    function setUp() public {
        wamos = new WamosV2(
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId,
            MINT_PRICE
        );
    }

    function testDeployed() public {}
}