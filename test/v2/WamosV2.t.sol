// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "./WamosV2TestHelper.sol";
import "~/v2/WamosV2.sol";
import "~/test/VRFCoordinatorV2Mock.sol";

contract WamosV2Test is Test, WamosV2TestHelper {

    WamosV2 wamos;
    
    // VRF COORD
    VRFCoordinatorV2Mock vrfCoordinator;
    uint64 subscriptionId;
    uint256[] requestIds;

    uint256 testRequestId;

    function setUp() public {
        // set up mock coordinator
        vrfCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        subscriptionId = vrfCoordinator.createSubscription();
        // deploy and confing wamos
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

    // DEPLOYMENT AND SUBSCRIPTION

    function testWamosIsDeployed() public {
        assertTrue(address(wamos) != address(0));
    }

    function testMockCoordinatorIsDeployed() public {
        assertFalse(address(vrfCoordinator) == address(0));
        console.log(subscriptionId);
    }

    function testWamosAddedAsConsumer() public {
        bool consumerIsAdded = vrfCoordinator.consumerIsAdded(
            subscriptionId,
            address(wamos)
        );
        assertTrue(consumerIsAdded);
    }

    function testSubscriptionIsFunded() public {
        (uint96 balance, , , address[] memory consumers) = vrfCoordinator
            .getSubscription(subscriptionId);
        assertTrue(balance == SUB_FUNDING);
        assertTrue(consumers[0] == address(wamos));
    }

    // MINTING REQUESTS

    function testRequestExists() public {
        vm.prank(player1);
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE }(1);
        (bool exists, bool isFulfilled, bool isCompleted,,,,) = wamos.getRequest(requestId);
        assertTrue(exists);
        assertFalse(isFulfilled);
        assertFalse(isCompleted);   
    }

    function testRequestIsFulfilled() public {
        vm.prank(player1);
        uint32 num = 4;
        uint256 requestId = wamos.requestSpawn{value: num*MINT_PRICE }(num);
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        (bool exists, bool isFulfilled, bool isCompleted,,,,uint256[] memory seeds) = wamos.getRequest(requestId);
        assertTrue(isFulfilled);
    }

    function testTestSpawnCompleted() public {
        vm.prank(player1);
        uint32 num = 5;
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE*num }(num);
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        wamos.completeSpawn(requestId);
        (
            bool exists,
            bool isFulfilled,
            bool isCompleted,
            address sender,
            uint256 firstWamoId,
            uint256 numWamos,
            uint256[] memory seeds
        ) = wamos.getRequest(requestId);
        assertTrue(exists);
        assertTrue(isFulfilled);
        assertTrue(isCompleted);
        assertTrue(firstWamoId == 1);
        assertFalse(seeds[0] == 0);
        assertTrue(seeds.length == num);
        console.log(seeds[0]);
        console.log(seeds[1]);
        console.log(seeds[2]);
        console.log(seeds[3]);
    }

    function testGRNGSingleOutput() public {}

}