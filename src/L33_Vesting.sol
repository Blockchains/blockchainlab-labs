// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {VestingWalletCliff} from "@openzeppelin/contracts/finance/VestingWalletCliff.sol";
import {VestingWallet} from "@openzeppelin/contracts/finance/VestingWallet.sol";

/// @title Lab 33 — Token vesting with a cliff (OpenZeppelin VestingWalletCliff).
contract TeamVesting is VestingWalletCliff {
    constructor(address beneficiary, uint64 start, uint64 duration, uint64 cliff)
        VestingWallet(beneficiary, start, duration)
        VestingWalletCliff(cliff)
    {}
}
