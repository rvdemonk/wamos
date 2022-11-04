// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

interface WamosRandomnessV0Interface {
    function requestRandomWords() external view returns (uint256 requestId);

    function getRequestStatus(uint256 requestID)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords);

    function doesRequestExist(uint256 _requestId)
        external
        view
        returns (bool doesExist);
}
