// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {DutchAuction} from "../src/L17_DutchAuction.sol";

contract L17Test is Test {
    DutchAuction a;
    address seller = makeAddr("seller");
    address bob = makeAddr("bob");

    function setUp() public {
        vm.prank(seller);
        a = new DutchAuction(10 ether, 2 ether, 8 days);
        vm.deal(bob, 20 ether);
    }

    function test_PriceDecay() public {
        assertEq(a.price(), 10 ether);
        vm.warp(block.timestamp + 4 days);
        assertEq(a.price(), 6 ether);
        vm.warp(block.timestamp + 10 days);
        assertEq(a.price(), 2 ether);
    }

    function test_BuyRefundsExcess() public {
        vm.warp(block.timestamp + 4 days);
        vm.prank(bob);
        a.buy{value: 7 ether}();
        assertEq(seller.balance, 6 ether);
        assertEq(bob.balance, 14 ether);
        assertEq(a.winner(), bob);
    }
}
