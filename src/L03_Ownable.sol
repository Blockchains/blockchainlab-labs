// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 03 — Access control with a two-step ownership transfer.
contract Owned {
    address public owner;
    address public pendingOwner;
    uint256 public fee;
    error NotOwner();
    error NotPending();
    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function setFee(uint256 f) external onlyOwner {
        fee = f;
    }

    function transferOwnership(address to) external onlyOwner {
        pendingOwner = to;
    }

    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert NotPending();
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
        pendingOwner = address(0);
    }
}
