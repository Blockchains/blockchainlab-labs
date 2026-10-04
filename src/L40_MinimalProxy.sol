// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title Lab 40 — EIP-1167 minimal proxies (clones): cheap per-user instances + deterministic addresses.
contract Wallet is Initializable {
    address public owner;

    constructor() {
        _disableInitializers(); // protect the implementation itself
    }

    function initialize(address o) external initializer {
        owner = o;
    }
}

contract WalletFactory {
    address public immutable implementation = address(new Wallet());
    event Created(address wallet, address owner);

    function create(address o) external returns (address w) {
        w = Clones.clone(implementation);
        Wallet(w).initialize(o);
        emit Created(w, o);
    }

    function createDeterministic(address o, bytes32 salt) external returns (address w) {
        w = Clones.cloneDeterministic(implementation, salt);
        Wallet(w).initialize(o);
    }

    function predict(bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt);
    }
}
