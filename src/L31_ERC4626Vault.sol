// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Lab 31 — ERC-4626 tokenised vault and the first-depositor inflation attack.
/// `NaiveVault` uses the textbook (pre-OZ-v4.9) share math with no virtual shares/assets; `SafeVault` uses OpenZeppelin's decimals offset (virtual shares).
contract NaiveVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Naive Vault", "nV") ERC4626(asset_) {}

    function _convertToShares(uint256 assets, Math.Rounding r) internal view override returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? assets : Math.mulDiv(assets, supply, totalAssets(), r);
    }

    function _convertToAssets(uint256 shares, Math.Rounding r) internal view override returns (uint256) {
        uint256 supply = totalSupply();
        return supply == 0 ? shares : Math.mulDiv(shares, totalAssets(), supply, r);
    }
}

contract SafeVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Safe Vault", "sV") ERC4626(asset_) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 6; // 10^6 virtual shares make the donation attack unprofitable
    }
}
