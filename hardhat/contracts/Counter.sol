// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/// @title Lab H1 — the Lab 02 counter, tested with Hardhat + ethers + chai instead of Foundry.
contract Counter {
    uint256 public count;
    event Incremented(address indexed by, uint256 newCount);
    error Underflow();
    function inc() external { emit Incremented(msg.sender, ++count); }
    function dec() external { if (count == 0) revert Underflow(); --count; }
}
