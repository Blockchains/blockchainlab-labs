// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Lab 21 — Constant-product AMM (x·y=k) with a 0.3% fee, LP shares and slippage protection.
contract ConstantProductAMM {
    IERC20 public immutable t0;
    IERC20 public immutable t1;
    uint256 public r0;
    uint256 public r1;
    uint256 public totalShares;
    mapping(address => uint256) public shares;
    error Slippage();
    error BadToken();

    constructor(IERC20 a, IERC20 b) {
        t0 = a;
        t1 = b;
    }

    function addLiquidity(uint256 a0, uint256 a1) external returns (uint256 s) {
        t0.transferFrom(msg.sender, address(this), a0);
        t1.transferFrom(msg.sender, address(this), a1);
        s = totalShares == 0 ? Math.sqrt(a0 * a1) : Math.min(a0 * totalShares / r0, a1 * totalShares / r1);
        shares[msg.sender] += s;
        totalShares += s;
        r0 += a0;
        r1 += a1;
    }

    function getAmountOut(uint256 amtIn, uint256 rIn, uint256 rOut) public pure returns (uint256) {
        uint256 inFee = amtIn * 997;
        return inFee * rOut / (rIn * 1000 + inFee);
    }

    function swap(IERC20 tokenIn, uint256 amtIn, uint256 minOut) external returns (uint256 out) {
        bool z = tokenIn == t0;
        if (!z && tokenIn != t1) revert BadToken();
        (uint256 rIn, uint256 rOut) = z ? (r0, r1) : (r1, r0);
        out = getAmountOut(amtIn, rIn, rOut);
        if (out < minOut) revert Slippage();
        tokenIn.transferFrom(msg.sender, address(this), amtIn);
        (z ? t1 : t0).transfer(msg.sender, out);
        if (z) {
            r0 += amtIn;
            r1 -= out;
        } else {
            r1 += amtIn;
            r0 -= out;
        }
    }

    function removeLiquidity(uint256 s) external returns (uint256 a0, uint256 a1) {
        a0 = s * r0 / totalShares;
        a1 = s * r1 / totalShares;
        shares[msg.sender] -= s;
        totalShares -= s;
        r0 -= a0;
        r1 -= a1;
        t0.transfer(msg.sender, a0);
        t1.transfer(msg.sender, a1);
    }
}
