// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 38 — EIP-1153 transient storage (TSTORE/TLOAD): a cheap reentrancy lock that clears itself.
contract TransientLockVault {
    mapping(address => uint256) public balance;
    bytes32 constant LOCK = keccak256("lab38.lock");
    error Reentrant();

    modifier nonReentrant() {
        bytes32 slot = LOCK;
        assembly {
            if tload(slot) {
                mstore(0, 0xed3ba6a6) // Reentrant()
                revert(0x1c, 4)
            }
            tstore(slot, 1)
        }
        _;
        assembly {
            tstore(slot, 0)
        }
    }

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() external nonReentrant {
        uint256 a = balance[msg.sender];
        (bool ok,) = msg.sender.call{value: a}(""); // interaction before effect: protected only by the lock
        require(ok, "send");
        balance[msg.sender] = 0;
    }

    function lockValue() external view returns (uint256 v) {
        bytes32 slot = LOCK;
        assembly {
            v := tload(slot)
        }
    }
}
