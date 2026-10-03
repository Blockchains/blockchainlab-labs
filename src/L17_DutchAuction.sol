// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 17 — Dutch auction: price decays linearly until someone buys.
contract DutchAuction {
    uint256 public immutable startPrice;
    uint256 public immutable floorPrice;
    uint256 public immutable start;
    uint256 public immutable duration;
    address public immutable seller;
    address public winner;
    error Ended();
    error TooLow();

    constructor(uint256 s, uint256 f, uint256 d) {
        startPrice = s;
        floorPrice = f;
        duration = d;
        start = block.timestamp;
        seller = msg.sender;
    }

    function price() public view returns (uint256) {
        uint256 e = block.timestamp - start;
        if (e >= duration) return floorPrice;
        return startPrice - (startPrice - floorPrice) * e / duration;
    }

    function buy() external payable {
        if (winner != address(0)) revert Ended();
        uint256 p = price();
        if (msg.value < p) revert TooLow();
        winner = msg.sender;
        payable(seller).transfer(p);
        if (msg.value > p) payable(msg.sender).transfer(msg.value - p);
    }
}
