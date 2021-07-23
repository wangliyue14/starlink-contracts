// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./interfaces/IStarlinkSateNFT.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/// @title StarlinkRewardVault
/// @notice A contract for generating rewards in the starlink ecosystem
contract StarlinkRewardVault is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event RewardClaimed(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 timestamp
    );

    IStarlinkSateNFT sateNft;
    IERC20 token;

    mapping(uint256 => uint256) lastUpdatedTime;

    constructor(IStarlinkSateNFT _sateNft, IERC20 _token) public {
        sateNft = _sateNft;
        token = _token;
    }

    function claimable(uint256 _tokenId) public view returns (uint256) {
        (, , uint256 stLaunchTime, uint256 stLaunchPrice, , uint8 stAPR) = sateNft.sateInfo(_tokenId);

        uint256 lastUpdated;
        if (stLaunchTime > lastUpdatedTime[_tokenId]) {
            if (stLaunchTime >= now()) return 0;

            lastUpdated = stLaunchTime;
        }
        else {
            lastUpdated = lastUpdatedTime[_tokenId];
        }
        return now().sub(lastUpdated).mul(stLaunchPrice).mul(stAPR).div(100).div(31536000);
    }

    function claimRewards(uint256 _tokenId) external {
        require(sateNft.ownerOf(_tokenId) == _msgSender(), "Must be owner");
        
        uint256 amount = claimable(_tokenId);
        if (amount > 0) {
            token.safeTransfer(_msgSender(), amount);
            lastUpdatedTime[_tokenId] = now();
            emit RewardClaimed(_tokenId, amount, now());
        }
    }

    function now() internal view returns (uint256) {
        return block.timestamp;
    }
}