// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SmartAccount} from "../src/L39_SmartAccount.sol";

contract L39Test is Test {
    SmartAccount acct;
    uint256 pk = 0xA11CE;
    address owner;
    address bob = makeAddr("bob");

    function setUp() public {
        owner = vm.addr(pk);
        acct = new SmartAccount(owner);
        vm.deal(address(acct), 5 ether);
    }

    function _sign(uint256 key, bytes32 h) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, MessageHashUtils.toEthSignedMessageHash(h));
        return abi.encodePacked(r, s, v);
    }

    function test_RelayedExecution() public {
        bytes memory sig = _sign(pk, acct.opHash(bob, 1 ether, "", 0));
        vm.prank(makeAddr("relayer"));
        acct.execute(bob, 1 ether, "", sig);
        assertEq(bob.balance, 1 ether);
        assertEq(acct.nonce(), 1);
    }

    function test_ReplayRejected() public {
        bytes memory sig = _sign(pk, acct.opHash(bob, 1 ether, "", 0));
        acct.execute(bob, 1 ether, "", sig);
        vm.expectRevert(SmartAccount.BadSig.selector);
        acct.execute(bob, 1 ether, "", sig);
    }

    function test_WrongSignerRejected() public {
        bytes memory sig = _sign(0xB0B, acct.opHash(bob, 1 ether, "", 0));
        vm.expectRevert(SmartAccount.BadSig.selector);
        acct.execute(bob, 1 ether, "", sig);
    }

    function test_ERC1271() public view {
        bytes32 h = keccak256("hello");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, h);
        assertEq(acct.isValidSignature(h, abi.encodePacked(r, s, v)), bytes4(0x1626ba7e));
        (v, r, s) = vm.sign(0xB0B, h);
        assertEq(acct.isValidSignature(h, abi.encodePacked(r, s, v)), bytes4(0xffffffff));
    }
}
