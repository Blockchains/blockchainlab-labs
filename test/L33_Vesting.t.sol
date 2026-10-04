// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TeamVesting} from "../src/L33_Vesting.sol";

contract T is ERC20 {
    constructor(address to) ERC20("T", "T") {
        _mint(to, 1200 ether);
    }
}

contract L33Test is Test {
    TeamVesting v;
    T t;
    address ben = makeAddr("ben");
    uint64 start;

    function setUp() public {
        start = uint64(block.timestamp);
        v = new TeamVesting(ben, start, 365 days, 90 days);
        t = new T(address(v));
    }

    function test_NothingBeforeCliff() public {
        vm.warp(start + 89 days);
        assertEq(v.releasable(address(t)), 0);
    }

    function test_LinearAfterCliff() public {
        vm.warp(start + 182.5 days);
        assertApproxEqAbs(v.releasable(address(t)), 600 ether, 1e15);
        v.release(address(t));
        assertApproxEqAbs(t.balanceOf(ben), 600 ether, 1e15);
    }

    function test_AllAfterEnd() public {
        vm.warp(start + 400 days);
        v.release(address(t));
        assertEq(t.balanceOf(ben), 1200 ether);
    }
}
