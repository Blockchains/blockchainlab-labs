// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/// @title Lab 43 — Signature replay across chains/contracts. A voucher signed without a domain separator
/// is valid on every fork, chain and redeployment; EIP-712 binds it to chainId + verifyingContract.
contract NaiveVoucher {
    address public immutable signer;
    mapping(bytes32 => bool) public used;

    constructor(address s) {
        signer = s;
    }

    function claim(address to, uint256 amt, uint256 n, bytes calldata sig) external returns (bool) {
        bytes32 h = keccak256(abi.encode(to, amt, n)); // no chainId, no contract address
        require(!used[h] && ECDSA.recover(h, sig) == signer, "bad");
        used[h] = true;
        return true;
    }
}

contract SafeVoucher is EIP712 {
    address public immutable signer;
    mapping(uint256 => bool) public used;
    bytes32 constant TYPEHASH = keccak256("Voucher(address to,uint256 amount,uint256 nonce)");

    constructor(address s) EIP712("SafeVoucher", "1") {
        signer = s;
    }

    function digest(address to, uint256 amt, uint256 n) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(TYPEHASH, to, amt, n)));
    }

    function claim(address to, uint256 amt, uint256 n, bytes calldata sig) external returns (bool) {
        require(!used[n] && ECDSA.recover(digest(to, amt, n), sig) == signer, "bad");
        used[n] = true;
        return true;
    }
}
