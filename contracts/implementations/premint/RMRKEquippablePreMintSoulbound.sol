// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.21;

import "./RMRKEquippablePreMint.sol";
import "../../RMRK/extension/soulbound/RMRKSoulbound.sol";

/**
 * @title RMRKEquippablePreMintSoulbound
 * @author RMRK team
 * @notice Implementation of non-transferable RMRK equippable module with pre-minting.
 */
contract RMRKEquippablePreMintSoulbound is
    RMRKSoulbound,
    RMRKEquippablePreMint
{
    /**
     * @notice Used to initialize the smart contract.
     * @param name Name of the token collection
     * @param symbol Symbol of the token collection
     * @param collectionMetadata CID of the collection metadata
     * @param maxSupply The maximum supply of tokens
     * @param royaltyRecipient Recipient of resale royalties
     * @param royaltyPercentageBps The percentage to be paid from the sale of the token expressed in basis points
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory collectionMetadata,
        uint256 maxSupply,
        address royaltyRecipient,
        uint16 royaltyPercentageBps
    )
        RMRKEquippablePreMint(
            name,
            symbol,
            collectionMetadata,
            maxSupply,
            royaltyRecipient,
            royaltyPercentageBps
        )
    {}

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(RMRKSoulbound, RMRKAbstractEquippable)
        returns (bool)
    {
        return
            RMRKAbstractEquippable.supportsInterface(interfaceId) ||
            RMRKSoulbound.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(RMRKSoulbound, RMRKAbstractEquippable) {
        RMRKSoulbound._beforeTokenTransfer(from, to, tokenId);
        RMRKAbstractEquippable._beforeTokenTransfer(from, to, tokenId);
    }
}
