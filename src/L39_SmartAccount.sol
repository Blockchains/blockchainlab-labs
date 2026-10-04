// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @title Lab 39 — Minimal smart account: owner-signed meta-transactions with nonces + ERC-1271.
/// The same validate-then-execute shape ERC-4337 accounts use (validateUserOp), without the EntryPoint.
contract SmartAccount {
    address public immutable owner;
    uint256 public nonce;
    error BadSig();

    constructor(address o) {
        owner = o;
    }

    receive() external payable {}

    function opHash(address to, uint256 value, bytes calldata data, uint256 n) public view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, address(this), to, value, keccak256(data), n));
    }

    /// Anyone (a relayer/bundler) can submit; only the owner's signature authorises.
    function execute(address to, uint256 value, bytes calldata data, bytes calldata sig)
        external
        returns (bytes memory)
    {
        bytes32 h = MessageHashUtils.toEthSignedMessageHash(opHash(to, value, data, nonce));
        if (ECDSA.recover(h, sig) != owner) revert BadSig();
        nonce++;
        (bool ok, bytes memory ret) = to.call{value: value}(data);
        require(ok, "call failed");
        return ret;
    }

    /// ERC-1271: lets dapps verify signatures "by" this contract.
    function isValidSignature(bytes32 hash, bytes calldata sig) external view returns (bytes4) {
        (address r, ECDSA.RecoverError e,) = ECDSA.tryRecover(hash, sig);
        return e == ECDSA.RecoverError.NoError && r == owner ? bytes4(0x1626ba7e) : bytes4(0xffffffff);
    }
}
