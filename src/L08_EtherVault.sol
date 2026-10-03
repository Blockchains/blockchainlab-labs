// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 08 — Holding ETH safely: receive, checks-effects-interactions, pull payments.
contract EtherVault {
    mapping(address => uint256) public balances;
    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);
    error Insufficient();
    error SendFailed();

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amt) external {
        if (balances[msg.sender] < amt) revert Insufficient();
        balances[msg.sender] -= amt; // effects before interaction
        (bool ok,) = msg.sender.call{value: amt}(""); // interaction last
        if (!ok) revert SendFailed();
        emit Withdraw(msg.sender, amt);
    }
}
