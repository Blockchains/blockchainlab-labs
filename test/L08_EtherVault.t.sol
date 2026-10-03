// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {EtherVault} from "../src/L08_EtherVault.sol";

contract L08Test is Test {
    EtherVault v;
    address alice = makeAddr("alice");

    function setUp() public {
        v = new EtherVault();
        vm.deal(alice, 5 ether);
    }

    function test_DepositViaReceive() public {
        vm.prank(alice);
        (bool ok,) = address(v).call{value: 1 ether}("");
        assertTrue(ok);
        assertEq(v.balances(alice), 1 ether);
    }

    function test_Withdraw() public {
        vm.startPrank(alice);
        v.deposit{value: 2 ether}();
        v.withdraw(1.5 ether);
        vm.stopPrank();
        assertEq(alice.balance, 4.5 ether);
    }

    function test_Overdraw() public {
        vm.prank(alice);
        vm.expectRevert(EtherVault.Insufficient.selector);
        v.withdraw(1);
    }
}
