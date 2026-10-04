// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {OracleConsumer, AggregatorV3Interface} from "../src/L37_OracleConsumer.sol";

contract MockFeed is AggregatorV3Interface {
    int256 public answer;
    uint256 public updatedAt;
    uint8 public decimals = 8;

    function set(int256 a, uint256 t) external {
        (answer, updatedAt) = (a, t);
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (1, answer, updatedAt, updatedAt, 1);
    }
}

contract L37Test is Test {
    MockFeed f;
    OracleConsumer c;

    function setUp() public {
        vm.warp(1_700_000_000);
        f = new MockFeed();
        c = new OracleConsumer(f, 1 hours);
        f.set(2500e8, block.timestamp);
    }

    function test_NormalisesTo18() public view {
        assertEq(c.price(), 2500e18);
        assertEq(c.valueOf(2e6, 6), 5000e18); // 2 tokens with 6 decimals
    }

    function test_RevertsWhenStale() public {
        vm.warp(block.timestamp + 1 hours + 1);
        vm.expectRevert(OracleConsumer.Stale.selector);
        c.price();
    }

    function test_RevertsOnNonPositive() public {
        f.set(0, block.timestamp);
        vm.expectRevert(OracleConsumer.BadAnswer.selector);
        c.price();
    }
}
