// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {BoxV1, BoxV2} from "../src/L23_UpgradeableProxy.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract L23Test is Test {
    BoxV1 box;
    address impl1;
    bytes32 constant IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function setUp() public {
        impl1 = address(new BoxV1());
        box = BoxV1(address(new ERC1967Proxy(impl1, abi.encodeCall(BoxV1.initialize, (address(this))))));
    }

    function test_SlotHoldsImplementation() public view {
        assertEq(address(uint160(uint256(vm.load(address(box), IMPL_SLOT)))), impl1);
        assertEq(IMPL_SLOT, bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    }

    function test_UpgradeKeepsState() public {
        box.set(41);
        box.upgradeToAndCall(address(new BoxV2()), "");
        BoxV2(address(box)).increment();
        assertEq(box.value(), 42);
        assertEq(box.version(), "v2");
    }

    function test_OnlyOwnerUpgrades() public {
        address v2 = address(new BoxV2());
        vm.prank(makeAddr("eve"));
        vm.expectRevert(bytes("owner"));
        box.upgradeToAndCall(v2, "");
    }

    function test_ImplCannotBeInitialised() public {
        vm.expectRevert();
        BoxV1(impl1).initialize(address(this));
    }
}
