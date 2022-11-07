// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

import "forge-std/Test.sol";
import "../src/v0/WamosRandomnessV0.sol";
import "../src/test/VRFCoordinatorV2Mock.sol";

contract WamosRandomnessV0Test is Test {
    // Coordinator init args
    uint96 BASE_FEE = 1;
    uint96 GAS_PRICE_LINK = 1;
    uint64 MOCK_VRF_SUB_ID = 1;
    uint96 SUB_FUNDING = 100000000000000000;
    bytes32 vrfKeyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    VRFCoordinatorV2Mock Coordinator;
    WamosRandomnessV0 VRFConsumer;

    uint64 subId;
    uint256 testWord;

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

    function testSubscriptionIsSetup() public {
        (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        ) = Coordinator.getSubscription(subId);
        assertTrue(balance > 0);
        assertTrue(balance == SUB_FUNDING);
        assertTrue(owner == address(this));
        assertTrue(consumers[0] == address(VRFConsumer));
    }

    function testMockConsumerAdded() public {
        bool isConsumerAdded = Coordinator.consumerIsAdded(
            subId,
            address(VRFConsumer)
        );
        assertTrue(isConsumerAdded);
    }

    function testRandomnessRequest() public {
        uint32 wordsRequested = 1;

        // first request
        uint256 reqId0 = VRFConsumer.requestRandomWords();
        uint256 reqCount0 = VRFConsumer.getRequestCount();
        assertTrue(reqCount0 == 1);

        // second request
        uint256 reqId1 = VRFConsumer.requestRandomWords();
        uint256 reqCount1 = VRFConsumer.getRequestCount();
        assertTrue(reqCount1 == 2);
    }

    function testRandomnessFulfilled() public {
        // make request
        uint256 reqId = VRFConsumer.requestRandomWords();
        bool reExists = VRFConsumer.doesRequestExist(reqId);
        // fufill random words as coordinator
        Coordinator.fulfillRandomWords(reqId, address(VRFConsumer));
        // retrieve status of request for test
        (bool status, uint256[] memory words) = VRFConsumer.getRequestStatus(
            reqId
        );
        assertTrue(status);
        testWord = words[0];
    }

    function testRandomWords() public {
        uint256 reqId;
        for (uint256 i = 0; i < 20; i++) {
            reqId = VRFConsumer.requestRandomWords();
            Coordinator.fulfillRandomWords(reqId, address(VRFConsumer));
            (, uint256[] memory words) = VRFConsumer.getRequestStatus(reqId);
            console.log("word #%s : %s", i, words[0]);
        }
    }
}
