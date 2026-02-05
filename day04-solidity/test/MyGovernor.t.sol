// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {MyGovernor} from "../src/MyGovernor.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract Box {
    uint256 public value;

    function store(uint256 newValue) external {
        value = newValue;
    }
}

contract MyGovernorTest is Test {
    PoolToken private token;
    MyGovernor private governor;

    address private alice = address(0xA11CE);

    function setUp() public {
        token = new PoolToken(1_000 ether);
        governor = new MyGovernor(token, 1, 50, 4);

        token.transfer(alice, 200 ether);
    }

    function testVotingParameters() public {
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 50);
        assertEq(governor.name(), "MyGovernor");
    }

    function testQuorumCalculation() public {
        vm.roll(block.number + 1);
        uint256 timepoint = block.number - 1;

        uint256 expected = (token.totalSupply() * 4) / 100;
        assertEq(governor.quorum(timepoint), expected);
    }

    function testCreateProposal() public {
        Box box = new Box();
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(box);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(Box.store, (42));

        string memory description = "Store value";
        uint256 currentBlock = block.number;

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        uint256 expectedSnapshot = currentBlock + governor.votingDelay();
        uint256 expectedDeadline = expectedSnapshot + governor.votingPeriod();

        assertEq(governor.proposalSnapshot(proposalId), expectedSnapshot);
        assertEq(governor.proposalDeadline(proposalId), expectedDeadline);
        assertEq(uint8(governor.state(proposalId)), uint8(0));
    }
}
