// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 30 — CREATE2: deterministic addresses you can know before deployment.
contract Wallet {
    address public immutable owner;

    constructor(address o) {
        owner = o;
    }
}

contract Create2Factory {
    event Deployed(address addr, bytes32 salt);

    function deploy(address owner, bytes32 salt) external returns (address w) {
        w = address(new Wallet{salt: salt}(owner));
        emit Deployed(w, salt);
    }

    function predict(address owner, bytes32 salt) external view returns (address) {
        bytes32 h = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(type(Wallet).creationCode, abi.encode(owner)))
            )
        );
        return address(uint160(uint256(h)));
    }
}
