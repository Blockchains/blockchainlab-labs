// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ConstantProductAMM} from "../src/L21_ConstantProductAMM.sol";

contract Tok is ERC20 {
    constructor(string memory n) ERC20(n, n) {}

    function mint(address to, uint256 a) external {
        _mint(to, a);
    }
}

/// @title Lab 41 — MEV sandwich attack on the lab-21 AMM, and how `minOut` (slippage protection) stops it.
/// Same pattern the Blockchain Lab Tools MEV checker detects on mainnet: front-run, victim, back-run.
contract L41Test is Test {
    Tok a;
    Tok b;
    ConstantProductAMM amm;
    address victim = makeAddr("victim");
    address mev = makeAddr("mev");

    function setUp() public {
        a = new Tok("A");
        b = new Tok("B");
        amm = new ConstantProductAMM(IERC20(address(a)), IERC20(address(b)));
        a.mint(address(this), 1000 ether);
        b.mint(address(this), 1000 ether);
        a.approve(address(amm), type(uint256).max);
        b.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1000 ether, 1000 ether);
        a.mint(victim, 100 ether);
        a.mint(mev, 300 ether);
        vm.prank(victim);
        a.approve(address(amm), type(uint256).max);
        vm.startPrank(mev);
        a.approve(address(amm), type(uint256).max);
        b.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function _sandwich(uint256 victimMinOut) internal returns (uint256 victimOut, int256 mevProfit) {
        vm.prank(mev);
        uint256 got = amm.swap(IERC20(address(a)), 300 ether, 0); // front-run: same direction
        vm.prank(victim);
        victimOut = amm.swap(IERC20(address(a)), 100 ether, victimMinOut);
        vm.prank(mev);
        uint256 back = amm.swap(IERC20(address(b)), got, 0); // back-run: reverse
        mevProfit = int256(back) - int256(300 ether);
    }

    function test_SandwichExtractsValue() public {
        uint256 fair = amm.getAmountOut(100 ether, amm.r0(), amm.r1());
        (uint256 out, int256 profit) = _sandwich(0);
        assertLt(out, fair * 70 / 100, "victim got >30% less than quoted");
        assertGt(profit, 0, "attacker profits");
    }

    function test_SlippageLimitBlocksSandwich() public {
        uint256 fair = amm.getAmountOut(100 ether, amm.r0(), amm.r1());
        uint256 minOut = fair * 995 / 1000; // 0.5% slippage tolerance
        vm.prank(mev);
        amm.swap(IERC20(address(a)), 300 ether, 0);
        vm.prank(victim);
        vm.expectRevert(ConstantProductAMM.Slippage.selector);
        amm.swap(IERC20(address(a)), 100 ether, minOut);
    }
}
