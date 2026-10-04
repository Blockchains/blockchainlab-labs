// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {RateLimitedVault} from "../src/L45_CircuitBreaker.sol";

contract L45Test is Test {
    RateLimitedVault v;
    address g = makeAddr("guardian");
    address u = makeAddr("user");

    function setUp() public {
        v = new RateLimitedVault(10 ether, 1 hours, g);
        vm.deal(u, 100 ether);
        vm.prank(u);
        v.deposit{value: 100 ether}();
    }

    function test_RateLimitPerWindow() public {
        vm.startPrank(u);
        v.withdraw(10 ether);
        vm.expectRevert(RateLimitedVault.RateLimited.selector);
        v.withdraw(1);
        vm.warp(block.timestamp + 1 hours);
        v.withdraw(10 ether);
        vm.stopPrank();
        assertEq(u.balance, 20 ether);
    }

    function test_GuardianPausesAdminUnpauses() public {
        vm.prank(g);
        v.pause();
        vm.prank(u);
        vm.expectRevert(Pausable.EnforcedPause.selector);
        v.withdraw(1 ether);
        vm.prank(g);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, g, bytes32(0)));
        v.unpause();
        v.unpause();
        vm.prank(u);
        v.withdraw(1 ether);
    }
}
