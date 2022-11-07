// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "src/v1/WamosV1.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

contract WamosBattleV1 is IERC721Receiver, VRFConsumerBaseV2 {
    // VRF COORDINATOR
    VRFCoordinatorV2Interface vrfCoordinator;

    // VRF CONFIGURATION
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    constructor(
        address wamosAddr, 
        address vrfCoordinatorAddr, 
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) VRFConsumerBaseV2(vrfCoordinatorAddr) 
    {
        // instantiate vrf coordinator
        vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorAddr);
        // configure coordinator variables
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfNumWords = 1;
        vrfCallbackGasLimit = 100000;
        vrfRequestConfirmations = 2;
    }

    // @dev TODO staking logic here
    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        
    }


}