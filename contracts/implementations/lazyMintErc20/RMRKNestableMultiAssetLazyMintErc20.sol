// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../abstract/RMRKAbstractNestableMultiAsset.sol";
import "../utils/RMRKTokenURIEnumerated.sol";
import "./InitDataERC20Pay.sol";

/**
 * @title RMRKNestableMultiAssetLazyMintErc20
 * @author RMRK team
 * @notice Implementation of joined RMRK nestable and multi asset module with ERC20-powered lazy minting.
 */
contract RMRKNestableMultiAssetLazyMintErc20 is
    InitDataERC20Pay,
    RMRKTokenURIEnumerated,
    RMRKAbstractNestableMultiAsset
{
    uint256 private _pricePerMint;
    address private _erc20TokenAddress;

    /**
     * @notice Used to initialize the smart contract.
     * @param name Name of the token collection
     * @param symbol Symbol of the token collection
     * @param collectionMetadata URI to the collection's metadata
     * @param baseTokenURI Each token's base URI
     * @param data The `InitData` struct used to pass initialization parameters
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory collectionMetadata,
        string memory baseTokenURI,
        InitData memory data
    )
        RMRKTokenURIEnumerated(baseTokenURI)
        RMRKImplementationBase(
            name,
            symbol,
            collectionMetadata,
            data.maxSupply,
            data.royaltyRecipient,
            data.royaltyPercentageBps
        )
    {
        _pricePerMint = data.pricePerMint;
        _erc20TokenAddress = data.erc20TokenAddress;
    }

    /**
     * @notice Used to mint the desired number of tokens to the specified address.
     * @dev The `data` value of the `_safeMint` method is set to an empty value.
     * @dev Can only be called while the open sale is open.
     * @param to Address to which to mint the token
     * @param numToMint Number of tokens to mint
     * @return The ID of the first token to be minted in the current minting cycle
     */
    function mint(
        address to,
        uint256 numToMint
    ) public payable virtual returns (uint256) {
        (uint256 nextToken, uint256 totalSupplyOffset) = _prepareMint(
            numToMint
        );
        _chargeMints(numToMint);

        for (uint256 i = nextToken; i < totalSupplyOffset; ) {
            _safeMint(to, i, "");
            unchecked {
                ++i;
            }
        }

        return nextToken;
    }

    /**
     * @notice Used to mint a desired number of child tokens to a given parent token.
     * @dev The `data` value of the `_safeMint` method is set to an empty value.
     * @dev Can only be called while the open sale is open.
     * @param to Address of the collection smart contract of the token into which to mint the child token
     * @param numToMint Number of tokens to mint
     * @param destinationId ID of the token into which to mint the new child token
     * @return The ID of the first token to be minted in the current minting cycle
     */
    function nestMint(
        address to,
        uint256 numToMint,
        uint256 destinationId
    ) public payable virtual returns (uint256) {
        (uint256 nextToken, uint256 totalSupplyOffset) = _prepareMint(
            numToMint
        );
        _chargeMints(numToMint);

        for (uint256 i = nextToken; i < totalSupplyOffset; ) {
            _nestMint(to, i, destinationId, "");
            unchecked {
                ++i;
            }
        }

        return nextToken;
    }

    function _chargeMints(uint256 numToMint) internal {
        uint256 price = numToMint * _pricePerMint;
        IERC20(_erc20TokenAddress).transferFrom(
            msg.sender,
            address(this),
            price
        );
    }

    /**
     * @notice Used to retrieve the address of the ERC20 token this smart contract supports.
     * @return Address of the ERC20 token's smart contract
     */
    function erc20TokenAddress() public view virtual returns (address) {
        return _erc20TokenAddress;
    }

    /**
     * @notice Used to retrieve the price per mint.
     * @return The price per mint of a single token expressed in the lowest denomination of a native currency
     */
    function pricePerMint() public view returns (uint256) {
        return _pricePerMint;
    }

    /**
     * @notice Used to withdraw the minting proceedings to a specified address.
     * @dev This function can only be called by the owner.
     * @param erc20 Address of the ERC20 token to withdraw
     * @param to Address to receive the given amount of minting proceedings
     * @param amount The amount to withdraw
     */
    function withdrawRaisedERC20(
        address erc20,
        address to,
        uint256 amount
    ) external onlyOwner {
        IERC20(erc20).transfer(to, amount);
    }
}
