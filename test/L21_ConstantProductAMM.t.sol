// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ConstantProductAMM} from "../src/L21_ConstantProductAMM.sol";
import {ScratchToken} from "../src/L04_ERC20Scratch.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract L21Test is Test {
    ScratchToken a;
    ScratchToken b;
    ConstantProductAMM amm;

    function setUp() public {
        a = new ScratchToken(1e30);
        b = new ScratchToken(1e30);
        amm = new ConstantProductAMM(IERC20(address(a)), IERC20(address(b)));
        a.approve(address(amm), type(uint256).max);
        b.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1_000 ether, 1_000 ether);
    }

    function test_SwapKIncreases() public {
        uint256 k0 = amm.r0() * amm.r1();
        uint256 out = amm.swap(IERC20(address(a)), 10 ether, 0);
        assertGt(out, 9.8 ether);
        assertLt(out, 10 ether);
        assertGe(amm.r0() * amm.r1(), k0);
    }

    function test_Slippage() public {
        vm.expectRevert(ConstantProductAMM.Slippage.selector);
        amm.swap(IERC20(address(a)), 10 ether, 10 ether);
    }

    function test_RemoveLiquidity() public {
        uint256 s = amm.shares(address(this));
        (uint256 x, uint256 y) = amm.removeLiquidity(s);
        assertEq(x, 1_000 ether);
        assertEq(y, 1_000 ether);
    }

    function testFuzz_KNeverDecreases(uint64 amt) public {
        vm.assume(amt > 1e6);
        uint256 k0 = amm.r0() * amm.r1();
        amm.swap(IERC20(address(b)), amt, 0);
        assertGe(amm.r0() * amm.r1(), k0);
    }
}
