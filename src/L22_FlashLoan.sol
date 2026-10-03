// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

/// @title Lab 22 — ERC-3156 flash lender: borrow, use and repay + fee within one transaction.
contract FlashLender {
    IERC20 public immutable token;
    uint256 public constant FEE_BPS = 9;
    bytes32 constant OK = keccak256("ERC3156FlashBorrower.onFlashLoan");
    error NotRepaid();
    error Callback();

    constructor(IERC20 t) {
        token = t;
    }

    function flashFee(address, uint256 amt) public pure returns (uint256) {
        return amt * FEE_BPS / 10_000;
    }

    function flashLoan(IERC3156FlashBorrower r, address t, uint256 amt, bytes calldata data) external returns (bool) {
        uint256 before = token.balanceOf(address(this));
        uint256 fee = flashFee(t, amt);
        token.transfer(address(r), amt);
        if (r.onFlashLoan(msg.sender, t, amt, fee, data) != OK) revert Callback();
        token.transferFrom(address(r), address(this), amt + fee);
        if (token.balanceOf(address(this)) < before + fee) revert NotRepaid();
        return true;
    }
}

contract Borrower is IERC3156FlashBorrower {
    bool public repay = true;
    uint256 public seen;

    function setRepay(bool r) external {
        repay = r;
    }

    function onFlashLoan(address, address t, uint256 amt, uint256 fee, bytes calldata) external returns (bytes32) {
        seen = IERC20(t).balanceOf(address(this));
        if (repay) IERC20(t).approve(msg.sender, amt + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
