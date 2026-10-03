// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {Unoptimised, Optimised} from "../src/L26_GasOptimisation.sol";

contract L26Test is Test {
    Unoptimised u;
    Optimised o;
    uint256[] v;

    function setUp() public {
        u = new Unoptimised();
        o = new Optimised();
        for (uint256 i; i < 50; i++) {
            v.push(i);
        }
    }

    function test_PackingSavesGas() public {
        uint256 g = gasleft();
        u.setBoth(1, 2);
        uint256 gu = g - gasleft();
        g = gasleft();
        o.setBoth(1, 2);
        uint256 go = g - gasleft();
        emit log_named_uint("unpacked", gu);
        emit log_named_uint("packed", go);
        assertLt(go, gu);
    }

    function test_LoopSavesGas() public {
        uint256 g = gasleft();
        u.sum(v);
        uint256 gu = g - gasleft();
        g = gasleft();
        o.sum(v);
        uint256 go = g - gasleft();
        emit log_named_uint("naive", gu);
        emit log_named_uint("optimised", go);
        assertLt(go, gu);
        assertEq(u.total(), o.total());
    }
}
