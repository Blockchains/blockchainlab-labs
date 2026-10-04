// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 34 — Pull-based ETH payment splitter by shares (no loops over payees on receive).
contract PaymentSplitter {
    uint256 public totalShares;
    uint256 public totalReleased;
    mapping(address => uint256) public shares;
    mapping(address => uint256) public released;
    error NoShares();
    error NothingDue();

    constructor(address[] memory payees, uint256[] memory s) {
        require(payees.length == s.length && payees.length > 0, "len");
        for (uint256 i; i < payees.length; i++) {
            require(shares[payees[i]] == 0 && s[i] > 0, "dup/zero");
            shares[payees[i]] = s[i];
            totalShares += s[i];
        }
    }

    receive() external payable {}

    function pending(address a) public view returns (uint256) {
        uint256 total = address(this).balance + totalReleased;
        return total * shares[a] / totalShares - released[a];
    }

    function release(address payable a) external {
        if (shares[a] == 0) revert NoShares();
        uint256 due = pending(a);
        if (due == 0) revert NothingDue();
        released[a] += due;
        totalReleased += due;
        (bool ok,) = a.call{value: due}("");
        require(ok, "send");
    }
}
