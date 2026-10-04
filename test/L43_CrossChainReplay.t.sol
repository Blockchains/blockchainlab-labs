// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {NaiveVoucher, SafeVoucher} from "../src/L43_CrossChainReplay.sol";

contract L43Test is Test {
    uint256 pk = 0x5161;
    address s;
    address alice = makeAddr("alice");

    function setUp() public {
        s = vm.addr(pk);
    }

    function _sig(bytes32 h) internal view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 ss) = vm.sign(pk, h);
        return abi.encodePacked(r, ss, v);
    }

    function test_NaiveReplaysOnAnotherChain() public {
        NaiveVoucher onMainnet = new NaiveVoucher(s);
        bytes memory sig = _sig(keccak256(abi.encode(alice, 1 ether, 1)));
        assertTrue(onMainnet.claim(alice, 1 ether, 1, sig));
        vm.chainId(8453); // same contract code redeployed on another chain
        NaiveVoucher onBase = new NaiveVoucher(s);
        assertTrue(onBase.claim(alice, 1 ether, 1, sig), "replayed!");
    }

    function test_EIP712BindsChainAndContract() public {
        SafeVoucher v1 = new SafeVoucher(s);
        bytes memory sig = _sig(v1.digest(alice, 1 ether, 1));
        assertTrue(v1.claim(alice, 1 ether, 1, sig));
        SafeVoucher v2 = new SafeVoucher(s); // different verifyingContract
        vm.expectRevert(bytes("bad"));
        v2.claim(alice, 1 ether, 1, sig);
        vm.chainId(8453);
        SafeVoucher v3 = new SafeVoucher(s);
        vm.expectRevert(bytes("bad"));
        v3.claim(alice, 1 ether, 1, sig);
    }

    function test_NonceStopsSameChainReplay() public {
        SafeVoucher v = new SafeVoucher(s);
        bytes memory sig = _sig(v.digest(alice, 1 ether, 7));
        v.claim(alice, 1 ether, 7, sig);
        vm.expectRevert(bytes("bad"));
        v.claim(alice, 1 ether, 7, sig);
    }
}
