// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IStarlinkSateNFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function creators(uint256 tokenId) external view returns (address);
    function isApproved(uint256 _tokenId, address _operator) external view returns (bool);
    function sateInfo(uint256 tokenId) external view returns (uint256, uint256, uint256, uint256, uint8, uint8);

    function setPrimarySalePrice(uint256 _tokenId, uint256 _salePrice) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
