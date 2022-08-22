// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "./IERC721.sol";

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol
/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function ERC721name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function ERC721symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
