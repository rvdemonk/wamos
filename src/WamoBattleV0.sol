// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev PRELIMINARY NOTES
 * For complex input validations use if statements + revert +custom errors;
 * use require statements only for simple checks
 *    - (reverts save gas apparently, plus more precise error me)
 */

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";

contract WamosBattleV0 is IERC721Receiver {
    IERC721 public wamosNFT;

    constructor(IERC721 _nft) {
        wamosNFT = _nft;
    }

    /**
     * @dev overrided for erc721 receiver
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external view override returns (bytes4) {
        require(msg.sender == address(wamosNFT));
        return IERC721Receiver.onERC721Received.selector;
    }
}
