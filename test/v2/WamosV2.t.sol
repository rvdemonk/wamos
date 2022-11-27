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
        vrfCoordinator.addConsumer(subscriptionId, address(wamos));
        vrfCoordinator.fundSubscription(subscriptionId, SUB_FUNDING);
        // fund players
        vm.deal(player1, ACTOR_STARTING_BAL);
        vm.deal(player2, ACTOR_STARTING_BAL);
        vm.deal(badActor, ACTOR_STARTING_BAL);
    }

    function testSpawnSingleRequest() public {
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE }(1);
        // request status
        (bool isFulfilled, bool isCompleted) = wamos.getRequestStatus(requestId);
        assertFalse(isFulfilled);
        assertFalse(isCompleted);
    }
}