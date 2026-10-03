// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 28 — Invariant testing: the vault's ETH must always cover every user's balance.
contract SimpleBank {
    mapping(address => uint256) public balanceOf;
    uint256 public totalDeposits;

    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 a) external {
        balanceOf[msg.sender] -= a;
        totalDeposits -= a;
        (bool ok,) = msg.sender.call{value: a}("");
        require(ok);
    }
}
