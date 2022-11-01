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

    // requestId => RequestStatus
    mapping(uint256 => RequestStatus) public s_requests;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    /// VRF HARDCODED VARIABLES
    // gas limit; change depending on network and experimentation
    uint32 callbackGasLimit = 100000;
    // blocks to confirm; default is 3
    uint16 requestConfirmations;
    // number of values to retrieve in one request
    uint32 numWords = 2;

    // GAS LANES (governs max gas price)
    // TODO extract these hardcodings into script file; take in constructor
    // goerli 150 gwei (only available)
    bytes32 GOERLI_KEYHASH =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    // mumbai 500 gwei (only available)
    bytes32 MUMBAI_KEYHASH =
        0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    // fuji 300 gwei (only available)
    bytes32 FUJI_KEYHASH =
        0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    //// COORDINATERS
    // TODO extract these hardcodings into script file; take in constructor
    // eth goerli testnet
    address GOERLI_COORDINATOR_ADDR =
        0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    // polygon mumbai testnet
    address MUMBAI_COORDINATOR_ADDR =
        0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    // avalanche fuji testnet
    address FUJI_COORDINATOR_ADDR = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;
    
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(MUMBAI_COORDINATOR_ADDR)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(MUMBAI_COORDINATOR_ADDR);
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
     * Using mumbai test net key hash
     */
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // generate request id from coordinator
        requestId = COORDINATOR.requestRandomWords(
            MUMBAI_KEYHASH,
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
        // store request id
        requestIds.push(requestId);
        // update last request id storage
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    // TODO
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "Request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }
}
