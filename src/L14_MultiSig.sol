// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Lab 14 — M-of-N multisig wallet: submit, confirm, execute.
contract MultiSig {
    struct Tx {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirms;
    }
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public immutable threshold;
    Tx[] public txs;
    mapping(uint256 => mapping(address => bool)) public confirmed;
    error NotOwner();
    error AlreadyConfirmed();
    error NotEnough();
    error Executed();
    error CallFailed();
    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    constructor(address[] memory o, uint256 t) {
        require(t > 0 && t <= o.length);
        for (uint256 i; i < o.length; i++) {
            isOwner[o[i]] = true;
            owners.push(o[i]);
        }
        threshold = t;
    }
    receive() external payable {}

    function submit(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256 id) {
        id = txs.length;
        txs.push(Tx(to, value, data, false, 0));
    }

    function confirm(uint256 id) external onlyOwner {
        if (confirmed[id][msg.sender]) revert AlreadyConfirmed();
        confirmed[id][msg.sender] = true;
        txs[id].confirms++;
    }

    function execute(uint256 id) external onlyOwner {
        Tx storage t = txs[id];
        if (t.executed) revert Executed();
        if (t.confirms < threshold) revert NotEnough();
        t.executed = true;
        (bool ok,) = t.to.call{value: t.value}(t.data);
        if (!ok) revert CallFailed();
    }
}
