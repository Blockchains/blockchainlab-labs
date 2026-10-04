// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title Lab 36 — Soulbound (non-transferable) credential NFT implementing ERC-5192 `locked()`.
contract SoulboundBadge is ERC721 {
    address public immutable issuer;
    event Locked(uint256 tokenId);
    error Soulbound();

    constructor() ERC721("Badge", "SBT") {
        issuer = msg.sender;
    }

    function issue(address to, uint256 id) external {
        require(msg.sender == issuer, "issuer");
        _mint(to, id);
        emit Locked(id);
    }

    function revoke(uint256 id) external {
        require(msg.sender == issuer, "issuer");
        _burn(id);
    }

    function locked(uint256 id) external view returns (bool) {
        _requireOwned(id);
        return true;
    }

    function _update(address to, uint256 id, address auth) internal override returns (address from) {
        from = _ownerOf(id);
        if (from != address(0) && to != address(0)) revert Soulbound(); // allow mint + burn only
        return super._update(to, id, auth);
    }

    function supportsInterface(bytes4 i) public view override returns (bool) {
        return i == 0xb45a3c0e || super.supportsInterface(i); // ERC-5192
    }
}
