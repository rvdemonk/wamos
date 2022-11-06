// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/WamosV1.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosV1Test is Test {
    uint96 BASE_FEE = 10000;
    uint96 GAS_PRICE_LINK = 10000;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 VRF_MOCK_KEYHASH =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint256 MINT_PRICE = 0.01 ether;

    address actor = 0x316DBF75409134CBcb1b3e0f013ABbfcF63CA040;
    uint256 ACTOR_STARTING_BAL = 1 ether;

    VRFCoordinatorV2Mock vrfCoordinator;
    WamosV1 wamos;
    uint64 subscriptionId;

    function setUp() public {
        // set up coordinator mock
        vrfCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        subscriptionId = vrfCoordinator.createSubscription();
        // deploy WamosV1
        wamos = new WamosV1(
            address(vrfCoordinator),
            VRF_MOCK_KEYHASH,
            subscriptionId,
            MINT_PRICE
        );
        // add wamos as consumer
        vrfCoordinator.addConsumer(subscriptionId, address(wamos));
        // fund subscription
        vrfCoordinator.fundSubscription(subscriptionId, SUB_FUNDING);
        // fund wallet
        vm.deal(actor, ACTOR_STARTING_BAL);
        console.log("Rvdemonk setup balance: %s", actor.balance);
    }

    function testWamosIsDeployed() public {
        assertTrue(address(wamos) != address(0));
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

    function testInitialTokenCount() public {
        assert(wamos.tokenCount() == 0);
    }

    /**
    TODO TESTS
    request spawn wamo
        request exists
        request fulfilled
        request stored
        last request stored
    complete spawn
        token minted
        trait generated and stored (health)

     */

    function testSpawnRequestDoesntExist() public {
        uint256 requestId = 0;
        // (bool exists, bool randomnessFulfilled, bool completed, , , ) = wamos
        //     .getSpawnRequest(tokenId);
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);
        assertFalse(request.exists);
        assertFalse(request.randomnessFulfilled);
        assertFalse(request.completed);
        // alternate method
        bool requestIsFulfilled = wamos.getSpawnRequestStatus(requestId);
        assertFalse(requestIsFulfilled);
    }

    function testSpawnRequestExists() public {
        uint256 mintPrice = wamos.mintPrice();
        vm.prank(actor);
        uint256 requestId = wamos.requestSpawnWamo{value: mintPrice}();
        SpawnRequest memory request = wamos.getSpawnRequest(requestId);
        assertTrue(request.exists);
    }
}
