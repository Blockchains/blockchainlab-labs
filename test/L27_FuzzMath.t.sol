// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {FeeHarness} from "../src/L27_FuzzMath.sol";

contract L27Test is Test {
    FeeHarness h;

    function setUp() public {
        h = new FeeHarness();
    }

    function testFuzz_FeeNeverExceedsAmount(uint128 a, uint16 b) public view {
        b = uint16(bound(b, 0, 10_000));
        uint256 r = h.good(a, b);
        assertLe(r, a);
        assertGe(r, uint256(a) * (10_000 - b) / 10_000);
    }

    function testFuzz_FeeIsAtMostOneUnitFromExact(uint128 a, uint16 b) public view {
        b = uint16(bound(b, 0, 10_000));
        uint256 fee = a - h.good(a, b);
        assertApproxEqAbs(fee * 10_000, uint256(a) * b, 10_000);
    }

    /// The buggy version charges ZERO fee on anything under 10,000 units — fuzzing finds this immediately.
    function test_BuggyVersionUndercharges() public view {
        assertEq(h.bad(9_999, 100), 9_999);
        assertEq(h.good(9_999, 100), 9_900);
    }
}
