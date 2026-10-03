// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Layout} from "../src/L25_StorageLayout.sol";

contract L25Test is Test {
    Layout l;

    function setUp() public {
        l = new Layout();
    }

    function test_Packed() public view {
        bytes32 s0 = vm.load(address(l), bytes32(0));
        assertEq(uint128(uint256(s0)), 1);
        assertEq(uint128(uint256(s0) >> 128), 2);
    }

    function test_Mapping() public view {
        assertEq(uint256(vm.load(address(l), keccak256(abi.encode(address(0xBEEF), uint256(2))))), 77);
    }

    function test_Array() public view {
        assertEq(uint256(vm.load(address(l), bytes32(uint256(3)))), 2);
        bytes32 base = keccak256(abi.encode(uint256(3)));
        assertEq(uint256(vm.load(address(l), bytes32(uint256(base) + 1))), 20);
    }

    function test_ShortString() public view {
        bytes32 s = vm.load(address(l), bytes32(uint256(4)));
        assertEq(uint8(uint256(s)), 13 * 2);
        assertEq(bytes13(s), bytes13("blockchainlab"));
    }
}
