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
    bytes1[] byteArr;

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

        // store test word
        uint256 reqId = VRFConsumer.requestRandomWords();
        Coordinator.fulfillRandomWords(reqId, address(VRFConsumer));
        // convert to bytes
        (, uint256[] memory words) = VRFConsumer.getRequestStatus(reqId);
        testWord = words[0];
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

    ////////  EXPERIMENTS WITH BYTES  /////////

    function testWordByte() public {
        uint256 reqId = VRFConsumer.requestRandomWords();
        Coordinator.fulfillRandomWords(reqId, address(VRFConsumer));
        // convert to bytes
        (, uint256[] memory words) = VRFConsumer.getRequestStatus(reqId);
        bytes memory wordB = _toBytes1(words[0]);
        console.log("random word: %s", words[0]);
        console.logBytes(wordB);
    }

    function _toBytes1(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            b[i] = bytes1(uint8(x / 2**(8 * (31 - i))));
        }
        return b;
    }

    function _toBytes2(uint256 x) private pure returns (bytes memory) {
        return abi.encode(x);
    }

    function testBytesConversionsAreEquivalent() public {
        bytes memory b = _toBytes1(testWord);
        bytes memory encoding = _toBytes2(testWord);
        assertEq(b, encoding);
    }

    function testBytesConvertManual() public {
        bytes memory b = _toBytes1(testWord);
    }

    function testBytesConvertEncode() public {
        bytes memory b = _toBytes2(testWord);
    }

    // function _spliceBytes(bytes32 calldata b) internal returns (bytes4) {
    //     return b[:4];
    // }

    // function testByteSplit() public {
    //     bytes32 b = _toBytes2(testWord);
    //     bytes4 subBytes = _spliceBytes(b);
    //     console.logBytes4(subBytes);
    // }

    function testByteSplit2() public {
        uint256 word = testWord;
        console.log(word);
        bytes memory b = abi.encode(testWord);
        console.logBytes(b);
        bytes1 sub0;
        bytes1 sub1;
        bytes1 sub2;
        // for (uint256 i = 0; i < 4; i++) {
        //     subb[i] = b[i];
        // }
        sub0 = b[0];
        sub1 = b[30];
        console.logBytes1(sub0);
        console.logBytes1(sub1);
    }

    function testByteSplitArray() public {
        bytes memory b = abi.encode(testWord);
        // bytes1[] storage byteArr;
        for (uint256 i = 0; i < 32; i++) {
            byteArr.push(b[i]);
        }
        console.logBytes1(byteArr[0]);
        console.logBytes1(byteArr[31]);
    }

    function testByteToUint() public {
        bytes memory b = abi.encode(testWord);
        // bytes1[] storage byteArr;
        for (uint256 i = 0; i < 32; i++) {
            byteArr.push(b[i]);
        }
        bytes1 b1 = byteArr[27];
        console.logBytes1(b1);
        uint256 n0 = uint256(bytes32(b1));
        console.log(n0);
    }
}
