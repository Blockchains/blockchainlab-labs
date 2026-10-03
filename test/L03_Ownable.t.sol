// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Owned} from "../src/L03_Ownable.sol";

contract L03Test is Test {
    Owned o;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        o = new Owned();
    }

    function test_OwnerCanSetFee() public {
        o.setFee(5);
        assertEq(o.fee(), 5);
    }

    function test_StrangerCannot() public {
        vm.prank(alice);
        vm.expectRevert(Owned.NotOwner.selector);
        o.setFee(1);
    }

    function test_TwoStepTransfer() public {
        o.transferOwnership(alice);
        assertEq(o.owner(), address(this));
        vm.prank(bob);
        vm.expectRevert(Owned.NotPending.selector);
        o.acceptOwnership();
        vm.prank(alice);
        o.acceptOwnership();
        assertEq(o.owner(), alice);
    }
}
