// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {FlashLender, Borrower} from "../src/L22_FlashLoan.sol";
import {ScratchToken} from "../src/L04_ERC20Scratch.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract L22Test is Test {
    ScratchToken t;
    FlashLender l;
    Borrower b;

    function setUp() public {
        t = new ScratchToken(1_000_000 ether);
        l = new FlashLender(IERC20(address(t)));
        b = new Borrower();
        t.transfer(address(l), 100_000 ether);
        t.transfer(address(b), 100 ether);
    }

    function test_FlashLoan() public {
        l.flashLoan(b, address(t), 10_000 ether, "");
        assertEq(b.seen(), 10_100 ether);
        assertEq(t.balanceOf(address(l)), 100_009 ether);
    }

    function test_NoRepayReverts() public {
        b.setRepay(false);
        vm.expectRevert();
        l.flashLoan(b, address(t), 10_000 ether, "");
    }
}
