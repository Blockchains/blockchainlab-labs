// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ScratchToken} from "../src/L04_ERC20Scratch.sol";

contract L04Test is Test {
    ScratchToken t;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        t = new ScratchToken(1_000 ether);
    }

    function test_Transfer() public {
        t.transfer(alice, 10 ether);
        assertEq(t.balanceOf(alice), 10 ether);
    }

    function test_TransferFrom() public {
        t.approve(alice, 5 ether);
        vm.prank(alice);
        t.transferFrom(address(this), bob, 5 ether);
        assertEq(t.balanceOf(bob), 5 ether);
        assertEq(t.allowance(address(this), alice), 0);
    }

    function test_InfiniteAllowanceNotDecremented() public {
        t.approve(alice, type(uint256).max);
        vm.prank(alice);
        t.transferFrom(address(this), bob, 1);
        assertEq(t.allowance(address(this), alice), type(uint256).max);
    }

    function test_RevertOverspend() public {
        vm.prank(alice);
        vm.expectRevert(bytes("balance"));
        t.transfer(bob, 1);
    }

    function testFuzz_SupplyConserved(uint96 a) public {
        vm.assume(a <= 1_000 ether);
        t.transfer(alice, a);
        assertEq(t.balanceOf(alice) + t.balanceOf(address(this)), t.totalSupply());
    }
}
