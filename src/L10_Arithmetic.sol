// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 10 — Checked vs unchecked arithmetic, and rounding direction.
contract Arithmetic {
    function checkedSub(uint8 a, uint8 b) external pure returns (uint8) {
        return a - b;
    }

    function uncheckedSub(uint8 a, uint8 b) external pure returns (uint8) {
        unchecked {
            return a - b;
        }
    }

    /// shares = assets * totalShares / totalAssets — round DOWN when minting shares to users
    function sharesDown(uint256 assets, uint256 ts, uint256 ta) external pure returns (uint256) {
        return assets * ts / ta;
    }

    /// round UP when computing what a user must pay
    function assetsUp(uint256 shares, uint256 ts, uint256 ta) external pure returns (uint256) {
        return (shares * ta + ts - 1) / ts;
    }
}
