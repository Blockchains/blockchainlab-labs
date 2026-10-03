// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @title Lab 13 — Off-chain signed vouchers (EIP-191 personal_sign) with nonces to stop replay.
contract VoucherRedeemer {
    using ECDSA for bytes32;
    address public immutable signer;
    mapping(uint256 => bool) public used;
    mapping(address => uint256) public points;
    error Used();
    error BadSig();

    constructor(address s) {
        signer = s;
    }

    function redeem(address to, uint256 amount, uint256 nonce, bytes calldata sig) external {
        if (used[nonce]) revert Used();
        bytes32 h = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encode(block.chainid, address(this), to, amount, nonce))
        );
        if (h.recover(sig) != signer) revert BadSig();
        used[nonce] = true;
        points[to] += amount;
    }
}
