// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {SoulboundBadge} from "../src/L36_Soulbound.sol";

contract L36Test is Test {
    SoulboundBadge b;
    address alice = makeAddr("alice");

    function setUp() public {
        b = new SoulboundBadge();
        b.issue(alice, 1);
    }

    function test_TransferReverts() public {
        vm.prank(alice);
        vm.expectRevert(SoulboundBadge.Soulbound.selector);
        b.transferFrom(alice, address(this), 1);
    }

    function test_LockedAndInterface() public view {
        assertTrue(b.locked(1));
        assertTrue(b.supportsInterface(0xb45a3c0e));
    }

    function test_IssuerCanRevoke() public {
        b.revoke(1);
        assertEq(b.balanceOf(alice), 0);
    }

    function test_OnlyIssuer() public {
        vm.prank(alice);
        vm.expectRevert(bytes("issuer"));
        b.issue(alice, 2);
    }
}
