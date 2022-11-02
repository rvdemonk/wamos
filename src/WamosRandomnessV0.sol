// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/ConfirmedOwner.sol";

/**
 * @notice PROTOTYPE CONTRACT
 * @notice CONTAINS HARDCODED VALUES
 * @notice NOT FOR PRODUCTION USE!!
 * @dev VRF consumer delegate for wamos system
 * Intended to generate randomness for wamo genesis, battles, breeding, gear
 */

contract WamosRandomnessV0 is VRFConsumerBaseV2, ConfirmedOwner {
    //// VRF CONSUMER DATA STORAGE
    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }

    bytes32 public keyHash;

    // requestId => RequestStatus
    mapping(uint256 => RequestStatus) public s_requests;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    /// VRF HARDCODED VARIABLES
    // blocks to confirm; default is 3
    uint16 requestConfirmations = 1;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event RequestFulfillmentATTEMPT();

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 vrfKeyHash
    ) VRFConsumerBaseV2(vrfCoordinator) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        keyHash = vrfKeyHash;
        s_subscriptionId = subscriptionId;
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
    function requestRandomWords(uint32 numWords, uint32 callbackGasLimit)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // generate request id from coordinator
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        // store request struct
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

    function getRequestCount() public view returns (uint256) {
        return requestIds.length;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        emit RequestFulfillmentATTEMPT();
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }
}
