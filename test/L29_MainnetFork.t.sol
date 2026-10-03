// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title Lab 29 — Mainnet fork testing against real deployed contracts (USDC, WETH) via a public RPC.
interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function balanceOf(address) external view returns (uint256);
}

contract L29Test is Test {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        string memory url = vm.envOr("MAINNET_RPC_URL", string("https://ethereum-rpc.publicnode.com"));
        // Fork a block ~32 behind head: public RPCs are load-balanced, and the very latest block may not
        // be on every backend yet, while non-archive nodes keep only recent state.
        bytes memory raw = vm.rpc(url, "eth_blockNumber", "[]"); // big-endian bytes of the quantity
        uint256 head;
        for (uint256 i; i < raw.length; i++) {
            head = (head << 8) | uint8(raw[i]);
        }
        vm.createSelectFork(url, head - 32);
    }

    function test_ReadRealUSDC() public view {
        assertEq(IERC20Metadata(USDC).symbol(), "USDC");
        assertEq(IERC20Metadata(USDC).decimals(), 6);
        assertGt(IERC20Metadata(USDC).totalSupply(), 1e9 * 1e6);
    }

    // Note: on a fork the default test address may already hold real WETH, so assert on deltas.
    function test_WrapUnwrapWETH() public {
        vm.deal(address(this), 1 ether);
        uint256 w0 = IWETH(WETH).balanceOf(address(this));
        IWETH(WETH).deposit{value: 1 ether}();
        assertEq(IWETH(WETH).balanceOf(address(this)) - w0, 1 ether);
        IWETH(WETH).withdraw(1 ether);
        assertEq(address(this).balance, 1 ether);
        assertEq(IWETH(WETH).balanceOf(address(this)), w0);
    }

    function test_DealUSDC() public {
        deal(USDC, address(this), 1_000e6);
        assertEq(IERC20Metadata(USDC).balanceOf(address(this)), 1_000e6);
    }
    receive() external payable {}
}
