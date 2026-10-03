// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @title Lab 23 — UUPS upgradeable contract behind an ERC-1967 proxy.
contract BoxV1 is Initializable, UUPSUpgradeable {
    address public owner;
    uint256 public value;

    constructor() {
        _disableInitializers();
    }

    function initialize(address o) external initializer {
        owner = o;
    }

    function set(uint256 v) external {
        value = v;
    }

    function version() external pure virtual returns (string memory) {
        return "v1";
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == owner, "owner");
    }
}

contract BoxV2 is BoxV1 {
    function increment() external {
        value += 1;
    }

    function version() external pure override returns (string memory) {
        return "v2";
    }
}
