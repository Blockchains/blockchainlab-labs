// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title Lab 07 — ERC-1155 game items (fungible + non-fungible in one contract).
contract GameItems is ERC1155 {
    uint256 public constant GOLD = 0;
    uint256 public constant SWORD = 1;

    constructor() ERC1155("https://blockchainlab.com/items/{id}.json") {
        _mint(msg.sender, GOLD, 1_000, "");
        _mint(msg.sender, SWORD, 1, "");
    }
}
