// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/L11_MerkleAirdrop.sol";

contract L11Test is Test {
    // Root and proofs generated with @openzeppelin/merkle-tree (same vector as the Blockchain Lab Tools hash page)
    bytes32 constant ROOT = 0xd4dee0beab2d53f2cc83e567171bd2820e49898130a22622b10ead383e90bd77;
    MerkleAirdrop a;

    function setUp() public {
        a = new MerkleAirdrop(ROOT);
    }

    function _p(bytes32 x) internal pure returns (bytes32[] memory p) {
        p = new bytes32[](1);
        p[0] = x;
    }

    function test_Claim() public {
        a.claim(
            0x1111111111111111111111111111111111111111,
            5 ether,
            _p(0xb92c48e9d7abe27fd8dfd6b5dfdbfb1c9a463f80c712b66f3a5180a090cccafc)
        );
        a.claim(
            0x2222222222222222222222222222222222222222,
            2.5 ether,
            _p(0xeb02c421cfa48976e66dfb29120745909ea3a0f843456c263cf8f1253483e283)
        );
        assertEq(a.credited(0x1111111111111111111111111111111111111111), 5 ether);
    }

    function test_WrongAmount() public {
        vm.expectRevert(MerkleAirdrop.BadProof.selector);
        a.claim(
            0x1111111111111111111111111111111111111111,
            6 ether,
            _p(0xb92c48e9d7abe27fd8dfd6b5dfdbfb1c9a463f80c712b66f3a5180a090cccafc)
        );
    }

    function test_DoubleClaim() public {
        bytes32[] memory p = _p(0xb92c48e9d7abe27fd8dfd6b5dfdbfb1c9a463f80c712b66f3a5180a090cccafc);
        a.claim(0x1111111111111111111111111111111111111111, 5 ether, p);
        vm.expectRevert(MerkleAirdrop.AlreadyClaimed.selector);
        a.claim(0x1111111111111111111111111111111111111111, 5 ether, p);
    }
}
