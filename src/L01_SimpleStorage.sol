// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 01 — Simple storage. Built by Blockchain Lab — https://blockchainlab.com
contract SimpleStorage {
    uint256 private value;

    function set(uint256 v) external {
        value = v;
    }

    function get() external view returns (uint256) {
        return value;
    }
}
