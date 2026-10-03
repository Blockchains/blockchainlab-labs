// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {LabNFT} from "../src/L06_NFT.sol";

contract L06Test is Test {
    LabNFT n;
    address alice = makeAddr("alice");
    address tre = makeAddr("treasury");

    function setUp() public {
        n = new LabNFT(tre);
        vm.deal(alice, 10 ether);
    }

    function test_Mint() public {
        vm.prank(alice);
        uint256 id = n.mint{value: 0.01 ether}();
        assertEq(n.ownerOf(id), alice);
        assertEq(n.tokenURI(1), "https://blockchainlab.com/nft/1");
    }

    function test_WrongPrice() public {
        vm.prank(alice);
        vm.expectRevert(LabNFT.WrongPrice.selector);
        n.mint{value: 1}();
    }

    function test_SoldOut() public {
        vm.startPrank(alice);
        for (uint256 i; i < 100; i++) {
            n.mint{value: 0.01 ether}();
        }
        vm.expectRevert(LabNFT.SoldOut.selector);
        n.mint{value: 0.01 ether}();
        vm.stopPrank();
        n.withdraw();
        assertEq(tre.balance, 1 ether);
    }
}
