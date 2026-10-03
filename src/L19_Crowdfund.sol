// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Lab 19 — ERC-20 crowdfunding with goal, deadline and refunds (uses SafeERC20).
contract Crowdfund {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    address public immutable creator;
    uint256 public immutable goal;
    uint256 public immutable deadline;
    uint256 public raised;
    bool public claimed;
    mapping(address => uint256) public pledged;
    error Closed();
    error Open();
    error GoalMissed();
    error GoalMet();

    constructor(IERC20 t, uint256 g, uint256 secs) {
        token = t;
        creator = msg.sender;
        goal = g;
        deadline = block.timestamp + secs;
    }

    function pledge(uint256 amt) external {
        if (block.timestamp >= deadline) revert Closed();
        pledged[msg.sender] += amt;
        raised += amt;
        token.safeTransferFrom(msg.sender, address(this), amt);
    }

    function claim() external {
        if (block.timestamp < deadline) revert Open();
        if (raised < goal) revert GoalMissed();
        require(msg.sender == creator && !claimed);
        claimed = true;
        token.safeTransfer(creator, raised);
    }

    function refund() external {
        if (block.timestamp < deadline) revert Open();
        if (raised >= goal) revert GoalMet();
        uint256 a = pledged[msg.sender];
        pledged[msg.sender] = 0;
        token.safeTransfer(msg.sender, a);
    }
}
