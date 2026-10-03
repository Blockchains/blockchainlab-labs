// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {VulnerableBank, FixedBank, Attacker, IBank} from "../src/L09_Reentrancy.sol";

contract L09Test is Test {
    address victim = makeAddr("victim");

    function test_AttackDrainsVulnerable() public {
        VulnerableBank b = new VulnerableBank();
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        b.deposit{value: 10 ether}();
        Attacker a = new Attacker(IBank(address(b)));
        a.attack{value: 1 ether}();
        assertEq(address(b).balance, 0);
        assertEq(address(a).balance, 11 ether);
    }

    function test_FixedBankResists() public {
        FixedBank b = new FixedBank();
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        b.deposit{value: 10 ether}();
        Attacker a = new Attacker(IBank(address(b)));
        vm.expectRevert();
        a.attack{value: 1 ether}();
        assertEq(address(b).balance, 10 ether);
    }
}
