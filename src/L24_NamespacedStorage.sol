// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 24 — ERC-7201 namespaced storage (collision-free layouts for upgradeable / modular contracts).
contract NamespacedVault {
    /// @custom:storage-location erc7201:blockchainlab.storage.Vault
    struct VaultStorage {
        uint256 total;
        mapping(address => uint256) balance;
    }

    // keccak256(abi.encode(uint256(keccak256("blockchainlab.storage.Vault")) - 1)) & ~bytes32(uint256(0xff))
    function slot() public pure returns (bytes32) {
        return keccak256(abi.encode(uint256(keccak256("blockchainlab.storage.Vault")) - 1)) & ~bytes32(uint256(0xff));
    }

    function _s() private pure returns (VaultStorage storage $) {
        bytes32 p = slot();
        assembly { $.slot := p }
    }

    function deposit(uint256 a) external {
        VaultStorage storage $ = _s();
        $.total += a;
        $.balance[msg.sender] += a;
    }

    function total() external view returns (uint256) {
        return _s().total;
    }
}
