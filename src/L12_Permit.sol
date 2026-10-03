// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title Lab 12 — EIP-2612 permit: gasless approvals via EIP-712 typed signatures.
contract PermitToken is ERC20, ERC20Permit {
    constructor() ERC20("Permit Token", "PRM") ERC20Permit("Permit Token") {
        _mint(msg.sender, 1_000 ether);
    }
}
