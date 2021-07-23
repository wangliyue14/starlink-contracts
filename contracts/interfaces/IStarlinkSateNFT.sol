// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IStarlinkSateNFT {
    function ownerOf(uint256 tokenId) external view returns(address);
    function sateInfo(uint256 tokenId) external view returns(uint256, uint256, uint256, uint256, uint8, uint8);
}
