// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./ERC721/StarlinkERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";

contract StarlinkSateNFT is StarlinkERC721("Starlink", "SATE"), ERC1155Receiver, Initializable {
    
}