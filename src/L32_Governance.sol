// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {
    GovernorVotesQuorumFraction
} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

/// @title Lab 32 — On-chain governance: ERC20Votes + OpenZeppelin Governor + Timelock.
contract GovToken is ERC20, ERC20Permit, ERC20Votes {
    constructor(address to) ERC20("Gov", "GOV") ERC20Permit("Gov") {
        _mint(to, 1_000_000 ether);
    }

    function _update(address f, address t, uint256 v) internal override(ERC20, ERC20Votes) {
        super._update(f, t, v);
    }

    function nonces(address o) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(o);
    }
}

contract LabGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    constructor(IVotes t, TimelockController tl)
        Governor("LabGovernor")
        GovernorSettings(1, 50, 0) // 1 block delay, 50 block voting period, no threshold
        GovernorVotes(t)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(tl)
    {}

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    function state(uint256 id) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(id);
    }

    function proposalNeedsQueuing(uint256 id) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return super.proposalNeedsQueuing(id);
    }

    function _queueOperations(uint256 id, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return super._queueOperations(id, t, v, c, d);
    }

    function _executeOperations(uint256 id, address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(id, t, v, c, d);
    }

    function _cancel(address[] memory t, uint256[] memory v, bytes[] memory c, bytes32 d)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(t, v, c, d);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }
}

/// Something only the timelock may change.
contract Treasury {
    address public immutable timelock;
    uint256 public grant;

    constructor(address tl) {
        timelock = tl;
    }

    function setGrant(uint256 g) external {
        require(msg.sender == timelock, "only timelock");
        grant = g;
    }
}
