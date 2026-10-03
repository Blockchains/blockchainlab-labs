// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Lab 20 — Staking rewards using the reward-per-token accumulator pattern (O(1) per user).
contract StakingRewards {
    IERC20 public immutable stakeToken; // reward units per second
    IERC20 public immutable rewardToken;
    uint256 public immutable rewardRate;
    uint256 public totalStaked;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdate;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public paid;
    mapping(address => uint256) public rewards;

    constructor(IERC20 s, IERC20 r, uint256 rate) {
        stakeToken = s;
        rewardToken = r;
        rewardRate = rate;
        lastUpdate = block.timestamp;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + (block.timestamp - lastUpdate) * rewardRate * 1e18 / totalStaked;
    }

    function earned(address a) public view returns (uint256) {
        return balanceOf[a] * (rewardPerToken() - paid[a]) / 1e18 + rewards[a];
    }
    modifier update(address a) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdate = block.timestamp;
        rewards[a] = earned(a);
        paid[a] = rewardPerTokenStored;
        _;
    }

    function stake(uint256 amt) external update(msg.sender) {
        totalStaked += amt;
        balanceOf[msg.sender] += amt;
        stakeToken.transferFrom(msg.sender, address(this), amt);
    }

    function withdraw(uint256 amt) external update(msg.sender) {
        totalStaked -= amt;
        balanceOf[msg.sender] -= amt;
        stakeToken.transfer(msg.sender, amt);
    }

    function getReward() external update(msg.sender) {
        uint256 r = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, r);
    }
}
