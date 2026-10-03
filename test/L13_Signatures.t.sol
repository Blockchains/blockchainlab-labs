// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {VoucherRedeemer} from "../src/L13_Signatures.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract L13Test is Test {
    uint256 pk = 0xB0B;
    VoucherRedeemer r;
    address alice = makeAddr("alice");

    function setUp() public {
        r = new VoucherRedeemer(vm.addr(pk));
    }

    function _sig(uint256 key, address to, uint256 amt, uint256 n) internal view returns (bytes memory) {
        (uint8 v, bytes32 a, bytes32 b) = vm.sign(
            key, MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encode(block.chainid, address(r), to, amt, n)))
        );
        return abi.encodePacked(a, b, v);
    }

    function test_Redeem() public {
        r.redeem(alice, 10, 1, _sig(pk, alice, 10, 1));
        assertEq(r.points(alice), 10);
    }

    function test_Replay() public {
        bytes memory s = _sig(pk, alice, 10, 1);
        r.redeem(alice, 10, 1, s);
        vm.expectRevert(VoucherRedeemer.Used.selector);
        r.redeem(alice, 10, 1, s);
    }

    function test_WrongSigner() public {
        vm.expectRevert(VoucherRedeemer.BadSig.selector);
        r.redeem(alice, 10, 2, _sig(0xBAD, alice, 10, 2));
    }

    function test_TamperedAmount() public {
        vm.expectRevert(VoucherRedeemer.BadSig.selector);
        r.redeem(alice, 11, 3, _sig(pk, alice, 10, 3));
    }
}
