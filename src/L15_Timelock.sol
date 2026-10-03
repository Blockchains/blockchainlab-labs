// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 15 — Timelock: queue an action, wait, then execute within a grace window.
contract Timelock {
    uint256 public constant DELAY = 2 days;
    uint256 public constant GRACE = 7 days;
    address public immutable admin;
    mapping(bytes32 => uint256) public eta;
    error NotAdmin();
    error NotQueued();
    error TooEarly();
    error Stale();
    error Failed();

    constructor() {
        admin = msg.sender;
    }

    function id(address to, uint256 v, bytes memory d, uint256 salt) public pure returns (bytes32) {
        return keccak256(abi.encode(to, v, d, salt));
    }

    function queue(address to, uint256 v, bytes calldata d, uint256 salt) external returns (bytes32 h) {
        if (msg.sender != admin) revert NotAdmin();
        h = id(to, v, d, salt);
        eta[h] = block.timestamp + DELAY;
    }

    function execute(address to, uint256 v, bytes calldata d, uint256 salt) external payable {
        bytes32 h = id(to, v, d, salt);
        uint256 e = eta[h];
        if (e == 0) revert NotQueued();
        if (block.timestamp < e) revert TooEarly();
        if (block.timestamp > e + GRACE) revert Stale();
        delete eta[h];
        (bool ok,) = to.call{value: v}(d);
        if (!ok) revert Failed();
    }
}

contract Param {
    uint256 public x;

    function set(uint256 v) external {
        x = v;
    }
}
