// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {TransientLockVault} from "../src/L38_TransientStorage.sol";

contract Attacker {
    TransientLockVault v;
    uint256 public reentered;

    constructor(TransientLockVault v_) {
        v = v_;
    }

    function go() external payable {
        v.deposit{value: msg.value}();
        v.withdraw();
    }

    receive() external payable {
        if (reentered == 0) {
            reentered = 1;
            try v.withdraw() {
                reentered = 2;
            } catch {
                reentered = 3; // blocked by the transient lock
            }
        }
    }
}

contract L38Test is Test {
    TransientLockVault v;

    function setUp() public {
        v = new TransientLockVault();
        vm.deal(address(v), 10 ether);
        v.deposit{value: 0}();
    }

    function test_ReentrancyBlocked() public {
        Attacker a = new Attacker(v);
        a.go{value: 1 ether}();
        assertEq(a.reentered(), 3);
        assertEq(address(a).balance, 1 ether, "only own deposit withdrawn");
    }

    function test_LockClearedAfterCall() public {
        v.deposit{value: 1 ether}();
        v.withdraw();
        assertEq(v.lockValue(), 0);
    }

    function test_SelectorConstant() public pure {
        assertEq(bytes4(TransientLockVault.Reentrant.selector), bytes4(0xed3ba6a6));
    }

    receive() external payable {}
}
