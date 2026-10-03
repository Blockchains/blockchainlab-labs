// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {CommitReveal} from "../src/L16_CommitReveal.sol";

contract L16Test is Test {
    CommitReveal c;
    address alice = makeAddr("alice");

    function setUp() public {
        c = new CommitReveal(1 days, 1 days);
    }

    function test_Flow() public {
        vm.prank(alice);
        c.commit(keccak256(abi.encode(alice, uint256(2), bytes32("salt"))));
        vm.prank(alice);
        vm.expectRevert(CommitReveal.Phase.selector);
        c.reveal(2, "salt");
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        c.reveal(2, "salt");
        assertEq(c.votes(2), 1);
    }

    function test_WrongReveal() public {
        vm.prank(alice);
        c.commit(keccak256(abi.encode(alice, uint256(1), bytes32("s"))));
        vm.warp(block.timestamp + 1 days);
        vm.prank(alice);
        vm.expectRevert(CommitReveal.Mismatch.selector);
        c.reveal(2, "s");
    }
}
