// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Timelock, Param} from "../src/L15_Timelock.sol";

contract L15Test is Test {
    Timelock t;
    Param p;
    bytes data;

    function setUp() public {
        t = new Timelock();
        p = new Param();
        data = abi.encodeCall(Param.set, (99));
    }

    function test_Flow() public {
        t.queue(address(p), 0, data, 1);
        vm.expectRevert(Timelock.TooEarly.selector);
        t.execute(address(p), 0, data, 1);
        vm.warp(block.timestamp + 2 days);
        t.execute(address(p), 0, data, 1);
        assertEq(p.x(), 99);
        vm.expectRevert(Timelock.NotQueued.selector);
        t.execute(address(p), 0, data, 1);
    }

    function test_Stale() public {
        t.queue(address(p), 0, data, 2);
        vm.warp(block.timestamp + 10 days);
        vm.expectRevert(Timelock.Stale.selector);
        t.execute(address(p), 0, data, 2);
    }
}
