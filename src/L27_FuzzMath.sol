// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 27 — Property-based fuzzing: find the bug the unit test missed.
library FeeMath {
    /// Correct: apply basis-point fee with full precision (OZ-style mulDiv not needed for these bounds)
    function afterFee(uint256 amount, uint16 bps) internal pure returns (uint256) {
        require(bps <= 10_000);
        return amount - amount * bps / 10_000;
    }

    /// Buggy on purpose: divides first and loses precision for small amounts. The fuzz test documents it.
    function afterFeeBuggy(uint256 amount, uint16 bps) internal pure returns (uint256) {
        require(bps <= 10_000);
        return amount - amount / 10_000 * bps;
    }
}

contract FeeHarness {
    function good(uint256 a, uint16 b) external pure returns (uint256) {
        return FeeMath.afterFee(a, b);
    }

    function bad(uint256 a, uint16 b) external pure returns (uint256) {
        return FeeMath.afterFeeBuggy(a, b);
    }
}
