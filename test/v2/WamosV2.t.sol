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

    function spawnWamoAs(address sender) private returns (uint256 wamoId) {
        vm.prank(sender);
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE}(1);
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        wamos.completeSpawn(requestId);
        (, , , , wamoId, , ) = wamos.getRequest(requestId);
    }

    function spawnWamoBatchAs(address sender, uint32 batchSize) private returns (uint256 firstWamoId) {
        vm.prank(sender);
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE*batchSize}(batchSize);
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        wamos.completeSpawn(requestId);
        (, , , , firstWamoId, , ) = wamos.getRequest(requestId);
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
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE}(1);
        (bool exists, bool isFulfilled, bool isCompleted, , , , ) = wamos
            .getRequest(requestId);
        assertTrue(exists);
        assertFalse(isFulfilled);
        assertFalse(isCompleted);
    }

    function testRequestIsFulfilled() public {
        vm.prank(player1);
        uint32 num = 4;
        uint256 requestId = wamos.requestSpawn{value: num * MINT_PRICE}(num);
        vrfCoordinator.fulfillRandomWords(requestId, address(wamos));
        (
            bool exists,
            bool isFulfilled,
            bool isCompleted,
            ,
            ,
            ,
            uint256[] memory seeds
        ) = wamos.getRequest(requestId);
        assertTrue(isFulfilled);
    }

    function testTestSpawnCompleted() public {
        vm.prank(player1);
        uint32 num = 5;
        uint256 requestId = wamos.requestSpawn{value: MINT_PRICE * num}(num);
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
    }

    function testTraitsNonZero() public {
        uint256 wamoId = spawnWamoAs(player1);
        assertTrue(wamos.ownerOf(wamoId) == player1);
        Traits memory traits = wamos.getTraits(wamoId);
        assertFalse(traits.health == 0);
        assertFalse(traits.luck == 0);
        assertFalse(traits.stamina == 0);
        assertFalse(traits.mana == 0);
    }

    function testMovementsNonZero() public {
        uint256 wamoId = spawnWamoAs(player1);
        int16[8] memory moves = wamos.getMovements(wamoId);
        for (uint256 i = 0; i < 8; i++) {
            assertFalse(moves[i] == 0);
        }
    }

    function testAbilitiesNonZero() public {
        uint256 wamoId = spawnWamoAs(player1);
        Ability[] memory abilities = wamos.getAbilities(wamoId);
        for (uint256 i = 0; i < 4; i++) {
            assertFalse(abilities[i].power == 0);
        }
    }

    function testWamoOwnership() public {
        uint256 wamoId = spawnWamoAs(player2);
        assertTrue(wamos.ownerOf(wamoId) == player2);
    }

    function testWamoOwnershipBatchOrder() public {
        uint256 initSupply = wamos.nextWamoId();
        uint32 batchSize = 9;
        uint256 firstWamoId = spawnWamoBatchAs(player2, batchSize);
        assertTrue(wamos.nextWamoId() == initSupply + batchSize);
        for (uint256 i=0; i<batchSize; i++) {
            assertTrue(wamos.ownerOf(firstWamoId+i) == player2);
        }
    }
}
