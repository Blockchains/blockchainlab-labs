// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 26 — Gas: storage packing, caching storage reads, calldata vs memory.
contract Unoptimised {
    uint256 public x;
    uint256 public y;
    uint256 public total;

    function setBoth(uint256 a, uint256 b) external {
        x = a;
        y = b;
    }

    function sum(uint256[] memory v) external {
        for (uint256 i = 0; i < v.length; i++) {
            total += v[i];
        }
    }
}

contract Optimised {
    uint128 public x;
    uint128 public y;
    uint256 public total;

    function setBoth(uint128 a, uint128 b) external {
        x = a; // one SSTORE slot
        y = b;
    }

    function sum(uint256[] calldata v) external {
        uint256 t = total;
        uint256 n = v.length;
        for (uint256 i; i < n;) {
            t += v[i];
            unchecked {
                ++i;
            }
        }
        total = t;
    }
}
