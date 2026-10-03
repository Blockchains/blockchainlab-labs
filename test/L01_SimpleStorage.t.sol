// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../src/L01_SimpleStorage.sol";

contract L01Test is Test {
    SimpleStorage s;

    function setUp() public {
        s = new SimpleStorage();
    }

    function test_DefaultIsZero() public view {
        assertEq(s.get(), 0);
    }

    function test_Set() public {
        s.set(42);
        assertEq(s.get(), 42);
    }

    function test_StorageSlot0() public {
        s.set(7);
        assertEq(uint256(vm.load(address(s), bytes32(0))), 7);
    }

    function testFuzz_Set(uint256 v) public {
        s.set(v);
        assertEq(s.get(), v);
    }
}
