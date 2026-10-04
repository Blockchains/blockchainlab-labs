// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test} from "forge-std/Test.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {GovToken, LabGovernor, Treasury} from "../src/L32_Governance.sol";

contract L32Test is Test {
    GovToken tok;
    TimelockController tl;
    LabGovernor gov;
    Treasury tr;

    function setUp() public {
        tok = new GovToken(address(this));
        tok.delegate(address(this));
        address[] memory none = new address[](0);
        tl = new TimelockController(1 days, none, none, address(this));
        gov = new LabGovernor(tok, tl);
        tl.grantRole(tl.PROPOSER_ROLE(), address(gov));
        tl.grantRole(tl.EXECUTOR_ROLE(), address(0));
        tr = new Treasury(address(tl));
        vm.roll(block.number + 1);
    }

    function test_FullProposalLifecycle() public {
        address[] memory t = new address[](1);
        uint256[] memory v = new uint256[](1);
        bytes[] memory c = new bytes[](1);
        t[0] = address(tr);
        c[0] = abi.encodeCall(Treasury.setGrant, (42));
        string memory desc = "Grant 42";
        uint256 id = gov.propose(t, v, c, desc);
        assertEq(uint256(gov.state(id)), uint256(IGovernor.ProposalState.Pending));
        vm.roll(block.number + 2);
        gov.castVote(id, 1);
        vm.roll(block.number + 51);
        assertEq(uint256(gov.state(id)), uint256(IGovernor.ProposalState.Succeeded));
        bytes32 dh = keccak256(bytes(desc));
        gov.queue(t, v, c, dh);
        vm.expectRevert();
        gov.execute(t, v, c, dh); // timelock delay not passed
        vm.warp(block.timestamp + 1 days + 1);
        gov.execute(t, v, c, dh);
        assertEq(tr.grant(), 42);
    }

    function test_DirectCallBlocked() public {
        vm.expectRevert(bytes("only timelock"));
        tr.setGrant(1);
    }

    function test_DelegationCheckpointsVotes() public {
        address bob = makeAddr("bob");
        tok.transfer(bob, 100 ether);
        assertEq(tok.getVotes(bob), 0, "undelegated tokens have no votes");
        vm.prank(bob);
        tok.delegate(bob);
        assertEq(tok.getVotes(bob), 100 ether);
    }
}
