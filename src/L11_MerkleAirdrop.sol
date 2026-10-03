// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Lab 11 — Merkle allowlist airdrop, compatible with OpenZeppelin StandardMerkleTree
/// (build the tree at https://blockchains.github.io/blockchainlab-tools/hash/).
contract MerkleAirdrop {
    bytes32 public immutable root;
    mapping(address => bool) public claimed;
    mapping(address => uint256) public credited;
    error AlreadyClaimed();
    error BadProof();

    constructor(bytes32 r) {
        root = r;
    }

    function claim(address account, uint256 amount, bytes32[] calldata proof) external {
        if (claimed[account]) revert AlreadyClaimed();
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verifyCalldata(proof, root, leaf)) revert BadProof();
        claimed[account] = true;
        credited[account] = amount;
    }
}
