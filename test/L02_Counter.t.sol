// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/L02_Counter.sol";

contract L02Test is Test {
    Counter c;
    event Incremented(address indexed by, uint256 newCount);

    function setUp() public {
        c = new Counter();
    }

    function test_IncEmits() public {
        vm.expectEmit(true, false, false, true);
        emit Incremented(address(this), 1);
        c.inc();
        assertEq(c.count(), 1);
    }

    function test_DecRevertsAtZero() public {
        vm.expectRevert(Counter.Underflow.selector);
        c.dec();
    }

    function test_IncDec() public {
        c.inc();
        c.inc();
        c.dec();
        assertEq(c.count(), 1);
    }
}
