// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

/// @title Lab 35 — NFT royalties with ERC-2981 (default + per-token override).
contract RoyaltyNFT is ERC721, ERC2981 {
    constructor(address artist) ERC721("Royalty", "ROY") {
        _setDefaultRoyalty(artist, 500); // 5%
    }

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function setTokenRoyalty(uint256 id, address r, uint96 bps) external {
        require(ownerOf(id) == msg.sender, "owner");
        _setTokenRoyalty(id, r, bps);
    }

    function supportsInterface(bytes4 i) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(i);
    }
}
