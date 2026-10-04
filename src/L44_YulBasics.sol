// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 44 — Inline assembly (Yul) basics: storage, memory, returndata, and why checks matter.
contract YulBasics {
    uint256 public stored; // slot 0

    function setYul(uint256 v) external {
        assembly {
            sstore(0, v)
        }
    }

    function getYul() external view returns (uint256 v) {
        assembly {
            v := sload(0)
        }
    }

    /// Sum an array reading calldata directly.
    function sum(uint256[] calldata xs) external pure returns (uint256 s) {
        assembly {
            for { let i := 0 } lt(i, xs.length) { i := add(i, 1) } {
                s := add(s, calldataload(add(xs.offset, mul(i, 0x20))))
            }
        }
    }

    /// Unchecked in Yul: wraps silently. Solidity 0.8 would revert.
    function addUnchecked(uint256 a, uint256 b) external pure returns (uint256 c) {
        assembly {
            c := add(a, b)
        }
    }

    function addChecked(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    /// keccak256 of two words using scratch space (0x00-0x3f).
    function hashPair(bytes32 a, bytes32 b) external pure returns (bytes32 h) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            h := keccak256(0x00, 0x40)
        }
    }

    /// Read any address's code size (EXTCODESIZE).
    function codeSize(address a) external view returns (uint256 n) {
        assembly {
            n := extcodesize(a)
        }
    }
}
