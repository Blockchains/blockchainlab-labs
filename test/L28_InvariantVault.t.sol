// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/L28_InvariantVault.sol";

contract Handler is Test {
    SimpleBank public bank;
    address[] public actors;
    uint256 public ghostDeposited;
    uint256 public ghostWithdrawn;

    constructor(SimpleBank b) {
        bank = b;
        for (uint256 i; i < 3; i++) {
            actors.push(makeAddr(string(abi.encodePacked("actor", i))));
        }
    }

    function deposit(uint256 who, uint256 amt) external {
        address a = actors[who % 3];
        amt = bound(amt, 0, 100 ether);
        vm.deal(a, amt);
        vm.prank(a);
        bank.deposit{value: amt}();
        ghostDeposited += amt;
    }

    function withdraw(uint256 who, uint256 amt) external {
        address a = actors[who % 3];
        amt = bound(amt, 0, bank.balanceOf(a));
        vm.prank(a);
        bank.withdraw(amt);
        ghostWithdrawn += amt;
    }
}

contract L28Test is Test {
    SimpleBank bank;
    Handler h;

    function setUp() public {
        bank = new SimpleBank();
        h = new Handler(bank);
        targetContract(address(h));
    }

    function invariant_Solvent() public view {
        assertEq(address(bank).balance, bank.totalDeposits());
    }

    function invariant_GhostAccounting() public view {
        assertEq(bank.totalDeposits(), h.ghostDeposited() - h.ghostWithdrawn());
    }
}
