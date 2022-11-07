// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/IERC721.sol";
import "src/v1/WamosV1.sol";

interface WamosV1Interface is IERC721 {
    function getWamoTraits(uint256 tokenId) external view returns (WamoTraits memory traits);
}