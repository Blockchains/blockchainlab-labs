// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 18 — English auction with pull-based refunds (avoids DoS by a reverting bidder).
contract EnglishAuction {
    address public immutable seller;
    uint256 public immutable end;
    address public highBidder;
    uint256 public highBid;
    bool public settled;
    mapping(address => uint256) public refunds;
    error Low();
    error Over();
    error NotOver();

    constructor(uint256 secs) {
        seller = msg.sender;
        end = block.timestamp + secs;
    }

    function bid() external payable {
        if (block.timestamp >= end) revert Over();
        if (msg.value <= highBid) revert Low();
        if (highBidder != address(0)) refunds[highBidder] += highBid;
        highBidder = msg.sender;
        highBid = msg.value;
    }

    function withdrawRefund() external {
        uint256 r = refunds[msg.sender];
        refunds[msg.sender] = 0;
        payable(msg.sender).transfer(r);
    }

    function settle() external {
        if (block.timestamp < end) revert NotOver();
        require(!settled);
        settled = true;
        payable(seller).transfer(highBid);
    }
}
