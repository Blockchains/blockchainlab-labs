// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, stdError} from "forge-std/Test.sol";
import {YulBasics} from "../src/L44_YulBasics.sol";

contract L44Test is Test {
    YulBasics y;

    function setUp() public {
        y = new YulBasics();
    }

    function test_StorageSlot0() public {
        y.setYul(42);
        assertEq(y.stored(), 42);
        assertEq(y.getYul(), 42);
        assertEq(uint256(vm.load(address(y), bytes32(0))), 42);
    }

    function testFuzz_SumMatchesSolidity(uint64[] memory raw) public view {
        uint256[] memory xs = new uint256[](raw.length);
        uint256 expect;
        for (uint256 i; i < raw.length; i++) {
            xs[i] = raw[i];
            expect += raw[i];
        }
        assertEq(y.sum(xs), expect);
    }

    function test_UncheckedWraps() public {
        assertEq(y.addUnchecked(type(uint256).max, 2), 1);
        vm.expectRevert(stdError.arithmeticError);
        y.addChecked(type(uint256).max, 2);
    }

    function test_HashPairMatches() public view {
        assertEq(y.hashPair("a", "b"), keccak256(abi.encode(bytes32("a"), bytes32("b"))));
    }

    function test_CodeSize() public {
        assertGt(y.codeSize(address(y)), 0);
        assertEq(y.codeSize(makeAddr("eoa")), 0);
    }
}
