// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {RoyaltyNFT} from "../src/L35_Royalties.sol";

contract L35Test is Test {
    RoyaltyNFT n;
    address artist = makeAddr("artist");

    function setUp() public {
        n = new RoyaltyNFT(artist);
        n.mint(address(this), 1);
    }

    function test_SupportsERC2981() public view {
        assertTrue(n.supportsInterface(type(IERC2981).interfaceId));
    }

    function test_DefaultRoyalty() public view {
        (address r, uint256 amt) = n.royaltyInfo(1, 2 ether);
        assertEq(r, artist);
        assertEq(amt, 0.1 ether);
    }

    function test_TokenOverride() public {
        address other = makeAddr("other");
        n.setTokenRoyalty(1, other, 1000);
        (address r, uint256 amt) = n.royaltyInfo(1, 1 ether);
        assertEq(r, other);
        assertEq(amt, 0.1 ether);
    }
}
