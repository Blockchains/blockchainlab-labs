// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 16 — Commit-reveal: hide a choice until everyone has committed (front-running defence).
contract CommitReveal {
    uint256 public immutable commitEnd;
    uint256 public immutable revealEnd;
    mapping(address => bytes32) public commits;
    mapping(uint256 => uint256) public votes;
    error Phase();
    error Mismatch();

    constructor(uint256 commitSecs, uint256 revealSecs) {
        commitEnd = block.timestamp + commitSecs;
        revealEnd = commitEnd + revealSecs;
    }

    function commit(bytes32 h) external {
        if (block.timestamp >= commitEnd) revert Phase();
        commits[msg.sender] = h;
    }

    function reveal(uint256 choice, bytes32 salt) external {
        if (block.timestamp < commitEnd || block.timestamp >= revealEnd) revert Phase();
        if (keccak256(abi.encode(msg.sender, choice, salt)) != commits[msg.sender]) revert Mismatch();
        delete commits[msg.sender];
        votes[choice]++;
    }
}
