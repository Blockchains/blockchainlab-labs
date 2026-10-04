// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {PaymentSplitter} from "../src/L34_PaymentSplitter.sol";

contract L34Test is Test {
    PaymentSplitter ps;
    address payable a = payable(makeAddr("a"));
    address payable b = payable(makeAddr("b"));

    function setUp() public {
        address[] memory p = new address[](2);
        uint256[] memory s = new uint256[](2);
        (p[0], p[1], s[0], s[1]) = (a, b, 3, 1);
        ps = new PaymentSplitter(p, s);
    }

    function test_SplitsByShares() public {
        payable(address(ps)).transfer(4 ether);
        ps.release(a);
        ps.release(b);
        assertEq(a.balance, 3 ether);
        assertEq(b.balance, 1 ether);
    }

    function test_LateReleaseStillCorrect() public {
        payable(address(ps)).transfer(4 ether);
        ps.release(a);
        payable(address(ps)).transfer(4 ether);
        ps.release(a);
        ps.release(b);
        assertEq(a.balance, 6 ether);
        assertEq(b.balance, 2 ether);
    }

    function test_NoDoubleClaim() public {
        payable(address(ps)).transfer(1 ether);
        ps.release(b);
        vm.expectRevert(PaymentSplitter.NothingDue.selector);
        ps.release(b);
    }

    function testFuzz_NeverPaysMoreThanReceived(uint96 x, uint96 y) public {
        vm.deal(address(this), uint256(x) + y);
        payable(address(ps)).transfer(x);
        if (ps.pending(a) > 0) ps.release(a);
        payable(address(ps)).transfer(y);
        if (ps.pending(b) > 0) ps.release(b);
        assertLe(a.balance + b.balance, uint256(x) + y);
    }
}
