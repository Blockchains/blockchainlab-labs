// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {GameItems} from "../src/L07_MultiToken.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract L07Test is Test, ERC1155Holder {
    GameItems g;
    address alice = makeAddr("alice");

    function setUp() public {
        g = new GameItems();
    }

    function test_Balances() public view {
        assertEq(g.balanceOf(address(this), 0), 1_000);
        assertEq(g.balanceOf(address(this), 1), 1);
    }

    function test_BatchTransfer() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 0;
        ids[1] = 1;
        uint256[] memory amts = new uint256[](2);
        amts[0] = 10;
        amts[1] = 1;
        g.safeBatchTransferFrom(address(this), alice, ids, amts, "");
        assertEq(g.balanceOf(alice, 0), 10);
        assertEq(g.balanceOf(alice, 1), 1);
    }
}
