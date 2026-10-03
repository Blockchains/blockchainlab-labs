// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {PermitToken} from "../src/L12_Permit.sol";

contract L12Test is Test {
    PermitToken t;
    uint256 ownerPk = 0xA11CE;
    address owner;
    address spender = makeAddr("spender");
    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function setUp() public {
        t = new PermitToken();
        owner = vm.addr(ownerPk);
        t.transfer(owner, 100 ether);
    }

    function _sign(uint256 v, uint256 deadline) internal view returns (uint8, bytes32, bytes32) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, v, t.nonces(owner), deadline));
        return vm.sign(ownerPk, keccak256(abi.encodePacked("\x19\x01", t.DOMAIN_SEPARATOR(), structHash)));
    }

    function test_Permit() public {
        (uint8 v, bytes32 r, bytes32 s) = _sign(50 ether, block.timestamp + 1 hours);
        t.permit(owner, spender, 50 ether, block.timestamp + 1 hours, v, r, s);
        assertEq(t.allowance(owner, spender), 50 ether);
        assertEq(t.nonces(owner), 1);
    }

    function test_ReplayFails() public {
        uint256 d = block.timestamp + 1;
        (uint8 v, bytes32 r, bytes32 s) = _sign(1, d);
        t.permit(owner, spender, 1, d, v, r, s);
        vm.expectRevert();
        t.permit(owner, spender, 1, d, v, r, s);
    }

    function test_Expired() public {
        uint256 d = block.timestamp;
        (uint8 v, bytes32 r, bytes32 s) = _sign(1, d);
        vm.warp(d + 1);
        vm.expectRevert();
        t.permit(owner, spender, 1, d, v, r, s);
    }
}
