// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {EnglishAuction} from "../src/L18_EnglishAuction.sol";

contract L18Test is Test {
    EnglishAuction a;
    address seller = makeAddr("seller");
    address x = makeAddr("x");
    address y = makeAddr("y");

    function setUp() public {
        vm.prank(seller);
        a = new EnglishAuction(1 days);
        vm.deal(x, 5 ether);
        vm.deal(y, 5 ether);
    }

    function test_Flow() public {
        vm.prank(x);
        a.bid{value: 1 ether}();
        vm.prank(y);
        a.bid{value: 2 ether}();
        vm.prank(x);
        vm.expectRevert(EnglishAuction.Low.selector);
        a.bid{value: 2 ether}();
        vm.prank(x);
        a.withdrawRefund();
        assertEq(x.balance, 5 ether);
        vm.expectRevert(EnglishAuction.NotOver.selector);
        a.settle();
        vm.warp(block.timestamp + 1 days);
        a.settle();
        assertEq(seller.balance, 2 ether);
        assertEq(a.highBidder(), y);
    }
}
