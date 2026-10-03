// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {NamespacedVault} from "../src/L24_NamespacedStorage.sol";

contract L24Test is Test {
    NamespacedVault v;

    function setUp() public {
        v = new NamespacedVault();
    }

    function test_DataLivesAtNamespace() public {
        v.deposit(5);
        assertEq(uint256(vm.load(address(v), v.slot())), 5);
        assertEq(uint256(vm.load(address(v), bytes32(0))), 0);
    }

    function test_EipVector() public pure {
        // Example from the ERC-7201 text: namespace "example.main"
        assertEq(
            keccak256(abi.encode(uint256(keccak256("example.main")) - 1)) & ~bytes32(uint256(0xff)),
            bytes32(0x183a6125c38840424c4a85fa12bab2ab606c4b6d0e7cc73c0c06ba5300eab500)
        );
    }
}
