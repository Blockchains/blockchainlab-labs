// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Create2Factory, Wallet} from "../src/L30_Create2Factory.sol";

contract L30Test is Test {
    Create2Factory f;
    address alice = makeAddr("alice");

    function setUp() public {
        f = new Create2Factory();
    }

    function test_PredictMatches() public {
        address p = f.predict(alice, "s1");
        address w = f.deploy(alice, "s1");
        assertEq(w, p);
        assertEq(Wallet(w).owner(), alice);
    }

    function test_SameSaltTwiceReverts() public {
        f.deploy(alice, "s2");
        vm.expectRevert();
        f.deploy(alice, "s2");
    }

    function test_DifferentOwnerDifferentAddress() public view {
        assertTrue(f.predict(alice, "s") != f.predict(address(1), "s"));
    }
}
