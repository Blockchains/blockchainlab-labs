// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Lab 45 — Incident response: guardian pause + per-window outflow rate limit (circuit breaker).
contract RateLimitedVault is Pausable, AccessControl {
    bytes32 public constant GUARDIAN = keccak256("GUARDIAN");
    uint256 public immutable maxOutflowPerWindow;
    uint256 public immutable window;
    uint256 public windowStart;
    uint256 public outflowInWindow;
    mapping(address => uint256) public balance;
    error RateLimited();

    constructor(uint256 maxOut, uint256 win, address guardian) {
        maxOutflowPerWindow = maxOut;
        window = win;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GUARDIAN, guardian);
    }

    function deposit() external payable whenNotPaused {
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint256 a) external whenNotPaused {
        if (block.timestamp >= windowStart + window) (windowStart, outflowInWindow) = (block.timestamp, 0);
        if (outflowInWindow + a > maxOutflowPerWindow) revert RateLimited();
        outflowInWindow += a;
        balance[msg.sender] -= a;
        (bool ok,) = msg.sender.call{value: a}("");
        require(ok);
    }

    function pause() external onlyRole(GUARDIAN) {
        _pause(); // guardian can stop the bleeding fast...
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(); // ...but only the (slower, e.g. timelocked) admin can resume
    }
}
