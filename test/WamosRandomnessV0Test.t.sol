// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/WamosRandomnessV0.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosRandomnessV0Test is Test {
    // Coordinator init args
    uint96 BASE_FEE = 500000000000000; // polygon premium
    uint96 GAS_PRICE_LINK = 1000000000; // 1e9

    uint64 MOCK_VRF_SUB_ID = 1;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 vrfKeyHash =
        0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;

    VRFCoordinatorV2Mock Coordinator;
    WamosRandomnessV0 VRFConsumer;
    uint64 subId;

    function setUp() public {
        // deploy mocks
        Coordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        // deploy randomness
        VRFConsumer = new WamosRandomnessV0(
            MOCK_VRF_SUB_ID,
            address(Coordinator),
            vrfKeyHash
        );
        // create coordinator subscription
        subId = Coordinator.createSubscription();
        // fund subscription
        Coordinator.fundSubscription(subId, SUB_FUNDING);
        Coordinator.addConsumer(subId, address(VRFConsumer));
    }

    function testMockConsumerAdded() public {
        bool isConsumerAdded = Coordinator.consumerIsAdded(
            subId,
            address(VRFConsumer)
        );
        assertTrue(isConsumerAdded);
    }

    function testSubscriptionIsFunded() public {
        (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        ) = Coordinator.getSubscription(subId);
        assertTrue(balance > 0);
        assertTrue(balance == SUB_FUNDING);
        console.log("sub balance: %s", balance);
        console.log("Subscription owner: %s", owner);
        console.log("this address %s:", address(this));
        console.log("request count: %s", reqCount);
        console.log("consumer no1: %s", consumers[0]);
        console.log("wamos randomness contract: %s", address(VRFConsumer));
    }

    function testRandomnessRequest() public {
        uint32 wordsRequested = 1;
        uint256 reqId = VRFConsumer.requestRandomWords(wordsRequested, 500000);
        (bool status, uint256[] memory words) = VRFConsumer.getRequestStatus(
            reqId
        );
        uint256 reqCount = VRFConsumer.getRequestCount();
        assertTrue(reqCount == 1);
    }

    function testRandomnessFulfilled() public {
        uint32 wordsRequested = 3;
        uint256 reqId = VRFConsumer.requestRandomWords(wordsRequested, 2000000);

        (bool status, uint256[] memory words) = VRFConsumer.getRequestStatus(
            reqId
        );

        assertTrue(status);

        console.log("status: %s", status);
        // assertTrue(words.length == wordsRequested);
    }
}
