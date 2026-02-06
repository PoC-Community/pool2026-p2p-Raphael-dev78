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

contract VaultGovernorTest is Test {
    PoolToken private token;
    MyGovernor private governor;

    address private alice = address(0xA11CE);

    function setUp() public {
        token = new PoolToken(1_000_000 ether);
        governor = new MyGovernor(token, 1, 50, 4);

        bool ok = token.transfer(alice, 200_000 ether);
        assertTrue(ok);
    }

    function testGovernorParameters() public view {
        assertEq(governor.votingDelay(), 1);
        assertEq(governor.votingPeriod(), 50);
        assertEq(governor.name(), "MyGovernor");
    }

    function testQuorumCalculation() public {
        vm.roll(block.number + 1);
        uint256 timepoint = block.number - 1;

        uint256 expected = 40_000 ether;
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

        vm.startPrank(alice);
        token.delegate(alice);
        vm.stopPrank();

        vm.roll(block.number + 1);

        string memory description = "Store value";
        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        assertTrue(proposalId != 0);
    }
}
