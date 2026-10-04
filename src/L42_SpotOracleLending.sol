// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ConstantProductAMM} from "./L21_ConstantProductAMM.sol";

/// @title Lab 42 — Price-oracle manipulation: a lending market that prices collateral from AMM *spot* reserves.
/// A single large swap (or flash loan) moves the spot price, letting an attacker over-borrow.
contract SpotOracleLending {
    ConstantProductAMM public immutable amm; // t0 = collateral, t1 = debt asset
    IERC20 public immutable collateral;
    IERC20 public immutable debt;
    mapping(address => uint256) public deposited;
    mapping(address => uint256) public borrowed;
    uint256 public constant LTV_BPS = 8000;
    /// When set, a trusted price (e.g. Chainlink, see lab 37) is used instead of spot. 1e18 = 1 debt per collateral.
    uint256 public fixedPrice;

    constructor(ConstantProductAMM a) {
        amm = a;
        collateral = a.t0();
        debt = a.t1();
    }

    function useTrustedPrice(uint256 p) external {
        fixedPrice = p;
    }

    function price() public view returns (uint256) {
        return fixedPrice != 0 ? fixedPrice : amm.r1() * 1e18 / amm.r0(); // spot: manipulable!
    }

    function deposit(uint256 amt) external {
        collateral.transferFrom(msg.sender, address(this), amt);
        deposited[msg.sender] += amt;
    }

    function borrow(uint256 amt) external {
        uint256 limit = deposited[msg.sender] * price() / 1e18 * LTV_BPS / 10_000;
        require(borrowed[msg.sender] + amt <= limit, "undercollateralised");
        borrowed[msg.sender] += amt;
        debt.transfer(msg.sender, amt);
    }
}
