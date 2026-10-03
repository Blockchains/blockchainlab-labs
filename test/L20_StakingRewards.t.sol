// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {StakingRewards} from "../src/L20_StakingRewards.sol";
import {ScratchToken} from "../src/L04_ERC20Scratch.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract L20Test is Test {
    ScratchToken s;
    ScratchToken r;
    StakingRewards p;
    address a = makeAddr("a");
    address b = makeAddr("b");

    function setUp() public {
        s = new ScratchToken(1_000 ether);
        r = new ScratchToken(1_000_000 ether);
        p = new StakingRewards(IERC20(address(s)), IERC20(address(r)), 1 ether);
        r.transfer(address(p), 1_000_000 ether);
        s.transfer(a, 100 ether);
        s.transfer(b, 100 ether);
        vm.prank(a);
        s.approve(address(p), type(uint256).max);
        vm.prank(b);
        s.approve(address(p), type(uint256).max);
    }

    function test_ProRata() public {
        vm.prank(a); // a earns 100
        p.stake(10 ether);
        vm.warp(block.timestamp + 100);
        vm.prank(b); // a 25, b 75
        p.stake(30 ether);
        vm.warp(block.timestamp + 100);
        assertApproxEqAbs(p.earned(a), 125 ether, 1e6);
        assertApproxEqAbs(p.earned(b), 75 ether, 1e6);
        vm.prank(a);
        p.getReward();
        assertApproxEqAbs(r.balanceOf(a), 125 ether, 1e6);
    }
}
