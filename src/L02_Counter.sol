// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 02 — Events and custom errors.
contract Counter {
    uint256 public count;
    event Incremented(address indexed by, uint256 newCount);
    event Decremented(address indexed by, uint256 newCount);
    error Underflow();

    function inc() external {
        emit Incremented(msg.sender, ++count);
    }

    function dec() external {
        if (count == 0) revert Underflow();
        emit Decremented(msg.sender, --count);
    }
}
