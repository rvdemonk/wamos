// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";

struct RequestStatus {
    bool fulfilled;
    bool exists;
    uint256[] randomWords;
}

contract WamosRandomnessV0 is VRFConsumerBaseV2 {
    /// VRF HARDCODED VARIABLES
    uint16 public requestConfirmations = 3;
    uint32 public callbackGasLimit = 400000;

    VRFCoordinatorV2Interface Coordinator;

    address public owner;
    bytes32 public keyHash;
    uint64 public s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // requestId => RequestStatus
    mapping(uint256 => RequestStatus) public s_requests;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event RequestFulfillmentATTEMPT();

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 vrfKeyHash
    ) VRFConsumerBaseV2(vrfCoordinator) {
        owner = msg.sender;
        Coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        keyHash = vrfKeyHash;
        s_subscriptionId = subscriptionId;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Must be contract owner");
        _;
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "Request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    /**
     * @dev Assumes subscription is sufficiently funded
     */
    function requestRandomWords(uint32 numWords)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // generate request id from coordinator
        requestId = Coordinator.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        // store request
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function setRequestConfirmations(uint16 _confirmations) public onlyOwner {
        requestConfirmations = _confirmations;
    }

    function setCallbackGasLimit(uint32 gasLimit) public onlyOwner {
        callbackGasLimit = gasLimit;
    }

    function getRequestCount() public view returns (uint256) {
        return requestIds.length;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }
}
