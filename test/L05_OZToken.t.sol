// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {OZToken} from "../src/L05_OZToken.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract L05Test is Test {
    OZToken t;
    address alice = makeAddr("alice");

    function setUp() public {
        t = new OZToken();
    }

    function test_Mint() public {
        t.mint(alice, 1 ether);
        assertEq(t.balanceOf(alice), 1 ether);
    }

    function test_OnlyMinter() public {
        bytes32 role = t.MINTER_ROLE();
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, alice, role));
        t.mint(alice, 1);
    }

    function test_Cap() public {
        t.mint(alice, 1_000_000 ether);
        vm.expectRevert(
            abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, 1_000_000 ether + 1, 1_000_000 ether)
        );
        t.mint(alice, 1);
    }
}
