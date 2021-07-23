// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./ERC721/StarlinkERC721.sol";
import "./StarlinkPlanetManager.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title StarlinkSateNFT
/// @notice A contract for virtual satellite in the starlink ecosystem
contract StarlinkSateNFT is StarlinkERC721("Starlink", "SATE") {
    /// @notice event emitted upon construction of this contract, used to bootstrap external indexers
    event SateContractDeployed();

    /// @notice event emitted when token URI is updated
    event SateTokenUriUpdated(
        uint256 indexed _tokenId,
        string _tokenUri
    );
    /// @notice event emitted when creator is updated
    event SateCreatorUpdated(
        uint256 indexed _tokenId,
        address _creator
    );

    /// @notice event emitted when satellite info
    event SateInfoUpdated(
        uint256 indexed _tokenId,
        uint256 _launchTime,
        uint256 _launchPrice,
        uint8 _apr
    );

    /// @dev Satellite Info for each Sate NFT
    struct SateInfo {
        uint256 st_planet;
        uint256 st_speed;
        uint256 st_launchTime;
        uint256 st_launchPrice;
        uint8 st_radius;
        uint8 st_apr;
    }

    /// @dev current max tokenId
    uint256 public tokenIdPointer;

    /// @dev TokenID -> Creator address
    mapping(uint256 => address) public creators;

    /// @dev TokenID -> Satellite Info
    mapping(uint256 => SateInfo) public sateInfo;

    /// @dev limit batching of tokens due to gas limit restrictions
    uint256 public BATCH_LIMIT;

    /// @dev Govern - EOA address before Governance goes live
    address public governance;

    modifier onlyGovernance() {
        require(governance == _msgSender(), "Sender must be governance.");
        _;
    }

    /**
     */
    constructor(address _governance) public {
        governance = _governance;
        tokenIdPointer = 0;
        BATCH_LIMIT = 10;
        emit SateContractDeployed();
    }

    /**
     @notice Mints a SATE AND when minting to a contract checks if the beneficiary is a 721 compatible
     @dev Only senders with either the minter or smart contract role can invoke this method
     @param _beneficiary Recipient of the NFT
     @param _tokenUri URI for the token being minted
     @param _creator NFT creator - will be required for issuing royalties from secondary sales
     @return uint256 The token ID of the token that was minted
     */
    function mint(
        address _beneficiary,
        string calldata _tokenUri,
        address _creator,
        uint256[2] memory _st_params256,
        uint8[2] memory _st_params8
    ) external onlyGovernance returns (uint256) {
        // Valid args
        _assertMintingParamsValid(_tokenUri, _creator);

        tokenIdPointer = tokenIdPointer.add(1);
        uint256 tokenId = tokenIdPointer;

        // Mint token and set token URI
        _safeMint(_beneficiary, tokenId);
        _tokenURIs[tokenId] = _tokenUri;

        // Associate nft creator
        creators[tokenId] = _creator;

        // Associate satellite info
        sateInfo[tokenId] = SateInfo(
            _st_params256[0],
            _st_params256[1],
            0,
            0,
            _st_params8[0],
            _st_params8[1]
        );

        return tokenId;
    }

    /**
     @notice Burns a SATE, releasing any composed 1155 tokens held by the token itself
     @dev Only the owner or an approved sender can call this method
     @param _tokenId the token ID to burn
     */
    function burn(uint256 _tokenId) public {
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || isApproved(_tokenId, operator),
            "Only NFT owner or approved"
        );

        // Destroy token mappings
        _burn(_tokenId);

        // Clean up creator mapping
        delete creators[_tokenId];
        delete sateInfo[_tokenId];
    }

    function _extractIncomingTokenId() internal pure returns (uint256) {
        // Extract out the embedded token ID from the sender
        uint256 _receiverTokenId;
        uint256 _index = msg.data.length - 32;
        assembly {_receiverTokenId := calldataload(_index)}
        return _receiverTokenId;
    }

    ///////////
    // Govern /
    ///////////

    /**
     @notice Updates the token URI of a given token
     @dev Only admin or smart contract
     @param _tokenId The ID of the token being updated
     @param _tokenUri The new URI
     */
    function setTokenURI(uint256 _tokenId, string calldata _tokenUri) external onlyGovernance {
        _tokenURIs[_tokenId] = _tokenUri;
        emit SateTokenUriUpdated(_tokenId, _tokenUri);
    }

    /**
     @notice Updates the token URI of a given token
     @dev Only admin or smart contract
     @param _tokenIds The ID of the tokens being updated
     @param _tokenUris The new URIs
     */
    function batchSetTokenURI(uint256[] memory _tokenIds, string[] calldata _tokenUris) external onlyGovernance {
        require(
            _tokenIds.length == _tokenUris.length,
            "Must have equal length arrays"
        );
        for( uint256 i; i< _tokenIds.length; i++){
            _tokenURIs[_tokenIds[i]] = _tokenUris[i];
            emit SateTokenUriUpdated(_tokenIds[i], _tokenUris[i]);
        }
    }

    /**
     @notice Updates the token URI of a given token
     @dev Only admin or smart contract
     @param _tokenIds The ID of the token being updated
     @param _creators The new URI
     */
    function batchSetCreator(uint256[] memory _tokenIds, address[] calldata _creators) external onlyGovernance {
        require(
            _tokenIds.length == _creators.length,
            "Must have equal length arrays"
        );
        for( uint256 i; i< _tokenIds.length; i++){
            creators[_tokenIds[i]] = _creators[i];
            emit SateCreatorUpdated(_tokenIds[i], _creators[i]);
        }
    }

    /**
     @notice Records the Ether price that a given token was sold for (in WEI)
     @dev Only admin or a smart contract can call this method
     @param _tokenIds The ID of the token being updated
     @param _salePrices The primary Ether sale price in WEI
     */
    function batchSetPrimarySalePrice(uint256[] memory _tokenIds, uint256[] memory _salePrices) external onlyGovernance {
        require(
            _tokenIds.length == _salePrices.length,
            "Must have equal length arrays"
        );
        for( uint256 i; i< _tokenIds.length; i++){
            _setPrimarySalePrice(_tokenIds[i], _salePrices[i]);
        }
    }

    /**
     @notice Records the Ether price that a given token was sold for (in WEI)
     @dev Only admin or a smart contract can call this method
     @param _tokenId The ID of the token being updated
     @param _salePrice The primary Ether sale price in WEI
     */
    function setPrimarySalePrice(uint256 _tokenId, uint256 _salePrice) external onlyGovernance {
        _setPrimarySalePrice(_tokenId, _salePrice);
    }

    /**
     @notice Set satellite launch time, SATE will start to earn rewards
     @dev Only Governance can call this method
     @param _tokenId The ID of the token being updated
     @param _timestamp Timestamp of launching satellite
     */
    function setSateLaunchTime(uint256 _tokenId, uint256 _timestamp) external onlyGovernance {
        _setSateLaunchTime(_tokenId, _timestamp);
    }

    /**
     @notice Set satellite launch time, SATE will start to earn rewards
     @dev Only Governance can call this method
     @param _tokenIds The ID of the token being updated
     @param _timestamps Timestamp of launching satellite
     */
    function batchSetSateLaunchTime(uint256[] memory _tokenIds, uint256[] memory _timestamps) external onlyGovernance {
        require(
            _tokenIds.length == _timestamps.length,
            "Must have equal length arrays"
        );
        
        for( uint256 i; i< _tokenIds.length; i++){
            _setSateLaunchTime(_tokenIds[i], _timestamps[i]);
        }
    }


    /////////////////
    // View Methods /
    /////////////////

    /**
     @notice View method for checking whether a token has been minted
     @param _tokenId ID of the token being checked
     */
    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    /**
     * @dev checks the given token ID is approved either for all or the single token ID
     */
    function isApproved(uint256 _tokenId, address _operator) public view returns (bool) {
        return isApprovedForAll(ownerOf(_tokenId), _operator) || getApproved(_tokenId) == _operator;
    }

    /////////////////////////
    // Internal and Private /
    /////////////////////////


    /**
     @notice Checks that the URI is not empty and the creator is a real address
     @param _tokenUri URI supplied on minting
     @param _creator Address supplied on minting
     */
    function _assertMintingParamsValid(string calldata _tokenUri, address _creator) pure internal {
        require(bytes(_tokenUri).length > 0, "Token URI is empty");
        require(_creator != address(0), "Creator is zero address");
    }

    /**
     @notice Records the Ether price that a given token was sold for (in WEI)
     @dev Only admin or a smart contract can call this method
     @param _tokenId The ID of the token being updated
     @param _salePrice The primary Ether sale price in WEI
     */
    function _setPrimarySalePrice(uint256 _tokenId, uint256 _salePrice) internal {
        require(_exists(_tokenId), "Token does not exist");
        require(_salePrice > 0, "Invalid sale price");
        SateInfo storage _sateInfo = sateInfo[_tokenId];
        require(_sateInfo.st_launchPrice == 0, "LaunchPrice is already set");

        // Only set it once
        _sateInfo.st_launchPrice = _salePrice;
        emit SateInfoUpdated(_tokenId, _sateInfo.st_launchTime, _salePrice, _sateInfo.st_apr);
    }

    /**
     @notice Set satellite launch time, SATE will start to earn rewards
     @dev Only Governance can call this method
     @param _tokenId The ID of the token being updated
     @param _timestamp Timestamp of launching satellite
     */
    function _setSateLaunchTime(uint256 _tokenId, uint256 _timestamp) internal {
        require(_exists(_tokenId), "Token does not exist");
        SateInfo storage _sateInfo = sateInfo[_tokenId];
        require(_sateInfo.st_launchTime == 0, "LaunchTime is already set");

        _sateInfo.st_launchTime = _timestamp;
        emit SateInfoUpdated(_tokenId, _timestamp, _sateInfo.st_launchPrice, _sateInfo.st_apr);
    }

    // Batch transfer
    /**
     * @dev See {IERC721-transferFrom} for batch
     */
    function batchTransferFrom(address _from, address _to, uint256[] memory _tokenIds) public {
        for( uint256 i; i< _tokenIds.length; i++){
            //solhint-disable-next-line max-line-length
            require(_isApprovedOrOwner(_msgSender(), _tokenIds[i]), "ERC721: transfer caller is not owner nor approved");
            _transfer(_from, _to, _tokenIds[i]);
        }
    }
    
    function batchTokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 length = balanceOf(owner);
        uint256[] memory _tokenIds = new uint256[](length);

        for( uint256 i; i< length; i++){
            _tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return _tokenIds;
    }

    function batchTokenURI(uint256[] memory tokenIds) external view returns (string[] memory) {
        uint256 length = tokenIds.length;

        string[] memory _tokenUris = new string[](length);
        for( uint256 i; i< length; i++){
            _tokenUris[i] = _tokenURIs[tokenIds[i]];
        }
        return _tokenUris;
    }
}