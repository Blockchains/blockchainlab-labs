// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Crowdfund} from "../src/L19_Crowdfund.sol";
import {ScratchToken} from "../src/L04_ERC20Scratch.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract L19Test is Test {
    ScratchToken t;
    Crowdfund c;
    address creator = makeAddr("creator");
    address alice = makeAddr("alice");

    function setUp() public {
        t = new ScratchToken(1_000 ether);
        t.transfer(alice, 100 ether);
        vm.prank(creator);
        c = new Crowdfund(IERC20(address(t)), 50 ether, 7 days);
        vm.prank(alice);
        t.approve(address(c), type(uint256).max);
    }

    function test_Success() public {
        vm.prank(alice);
        c.pledge(60 ether);
        vm.warp(block.timestamp + 7 days);
        vm.prank(creator);
        c.claim();
        assertEq(t.balanceOf(creator), 60 ether);
    }

    function test_Refund() public {
        vm.prank(alice);
        c.pledge(10 ether);
        vm.warp(block.timestamp + 7 days);
        vm.prank(alice);
        c.refund();
        assertEq(t.balanceOf(alice), 100 ether);
        vm.prank(creator);
        vm.expectRevert(Crowdfund.GoalMissed.selector);
        c.claim();
    }
}
