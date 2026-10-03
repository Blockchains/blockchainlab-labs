// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {MultiSig} from "../src/L14_MultiSig.sol";

contract L14Test is Test {
    MultiSig w;
    address a = makeAddr("a");
    address b = makeAddr("b");
    address c = makeAddr("c");
    address payee = makeAddr("payee");

    function setUp() public {
        address[] memory o = new address[](3);
        o[0] = a;
        o[1] = b;
        o[2] = c;
        w = new MultiSig(o, 2);
        vm.deal(address(w), 3 ether);
    }

    function test_TwoOfThree() public {
        vm.prank(a);
        uint256 id = w.submit(payee, 1 ether, "");
        vm.prank(a);
        w.confirm(id);
        vm.prank(a);
        vm.expectRevert(MultiSig.NotEnough.selector);
        w.execute(id);
        vm.prank(b);
        w.confirm(id);
        vm.prank(c);
        w.execute(id);
        assertEq(payee.balance, 1 ether);
        vm.prank(c);
        vm.expectRevert(MultiSig.Executed.selector);
        w.execute(id);
    }

    function test_OutsiderBlocked() public {
        vm.prank(payee);
        vm.expectRevert(MultiSig.NotOwner.selector);
        w.submit(payee, 1, "");
    }
}
