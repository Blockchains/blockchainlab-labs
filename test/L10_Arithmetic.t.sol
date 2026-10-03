// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, stdError} from "forge-std/Test.sol";
import {Arithmetic} from "../src/L10_Arithmetic.sol";

contract L10Test is Test {
    Arithmetic m;

    function setUp() public {
        m = new Arithmetic();
    }

    function test_CheckedReverts() public {
        vm.expectRevert(stdError.arithmeticError);
        m.checkedSub(0, 1);
    }

    function test_UncheckedWraps() public view {
        assertEq(m.uncheckedSub(0, 1), 255);
    }

    function test_Rounding() public view {
        assertEq(m.sharesDown(10, 3, 7), 4);
        assertEq(m.assetsUp(4, 3, 7), 10);
    }

    function testFuzz_UpGteDown(uint64 s, uint64 ts, uint64 ta) public view {
        vm.assume(ts > 0 && ta > 0);
        assertGe(m.assetsUp(s, ts, ta) * uint256(ts), uint256(s) * ta);
    }
}
