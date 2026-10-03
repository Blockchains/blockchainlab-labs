// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 25 — Storage layout: packing, mappings, dynamic arrays and strings, read with vm.load.
contract Layout {
    uint128 public a = 1; // slot 0 (packed)
    uint128 public b = 2;
    uint256 public c = 3; // slot 1
    mapping(address => uint256) public bal; // slot 2 (values at keccak256(key . 2))
    uint256[] public arr; // slot 3 (length), data at keccak256(3)
    string public shortStr = "blockchainlab"; // slot 4 (short string: data + len*2 inline)

    constructor() {
        bal[address(0xBEEF)] = 77;
        arr.push(10);
        arr.push(20);
    }
}
