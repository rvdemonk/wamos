// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/WamosV0.sol";
import "../src/WamosRandomnessV0.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosV0Test is Test {
    address wamosOwner = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;

    uint96 BASE_FEE = 1;
    uint96 GAS_PRICE_LINK = 1;
    uint64 MOCK_VRF_SUB_ID = 1;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 VRF_MOCK_KEYHASH =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    WamosV0 wamos;
    WamosRandomnessV0 randomness;
    VRFCoordinatorV2Mock vrfCoordinator;

    uint64 subscriptionId;

    function setUp() public {
        // SET UP MOCKS
        // deploy mock coordinator
        vrfCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        // deploy vrf consumer
        randomness = new WamosRandomnessV0(
            MOCK_VRF_SUB_ID,
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH
        );
        // set up vrf subscription with coordinator
        subscriptionId = vrfCoordinator.createSubscription();
        // fund subscription
        vrfCoordinator.fundSubscription(subscriptionId, SUB_FUNDING);
        // add wamos randomness as vrf consumer to subscription
        vrfCoordinator.addConsumer(subscriptionId, address(vrfCoordinator));
        // deploy wamos nft
        // vm.prank(wamosOwner`);
        wamos = new WamosV0(address(randomness));
    }

    function testIsDeployed() public {
        assertTrue(address(wamos) != address(0));
    }

    function testInitialTokenCount() public {
        assertTrue(wamos.tokenCount() == 0);
    }

    function testMintTokenCountIncrement() public {
        /**
        [FAIL. Reason: Must be contract owner]
        Test contract owns Wamos and WamosRandomness.
        Wamos is calling WamosRandomness, but is not owner.
         */
        uint256 startingCount = wamos.tokenCount();
        // vm.prank(wamosOwner);
        uint256 newWamoId = wamos.spawn();
        uint256 newCount = wamos.tokenCount();
        assertTrue(newCount == startingCount + 1);
    }

    function testTestFunction() public {
        bool isSuccessful = wamos.testFunction();
        assertTrue(isSuccessful);
    }
}
