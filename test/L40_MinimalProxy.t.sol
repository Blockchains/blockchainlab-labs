// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Wallet, WalletFactory} from "../src/L40_MinimalProxy.sol";

contract L40Test is Test {
    WalletFactory f;

    function setUp() public {
        f = new WalletFactory();
    }

    function test_CloneIs45Bytes() public {
        address w = f.create(address(this));
        assertEq(w.code.length, 45);
        assertEq(Wallet(w).owner(), address(this));
    }

    function test_CannotReinitialize() public {
        address w = f.create(address(this));
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        Wallet(w).initialize(address(1));
    }

    function test_ImplementationLocked() public {
        Wallet impl = Wallet(f.implementation());
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize(address(1));
    }

    function test_DeterministicAddress() public {
        bytes32 salt = keccak256("alice");
        address p = f.predict(salt);
        assertEq(f.createDeterministic(address(this), salt), p);
    }

    function test_CloneStoresFarLessCode() public {
        // Deployment cost is dominated by 200 gas per byte of runtime code stored.
        address w = f.create(address(this));
        uint256 implCode = f.implementation().code.length;
        assertGt(implCode, 45 * 5, "implementation is much larger than the 45-byte clone");
        assertEq(w.code.length, 45);
    }
}
