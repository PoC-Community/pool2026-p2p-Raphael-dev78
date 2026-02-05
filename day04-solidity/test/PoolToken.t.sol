// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTest is Test {
    PoolToken private token;

    address private alice = address(0xA11CE);
    address private bob = address(0xB0B);

    function setUp() public {
        token = new PoolToken(1_000 ether);
        token.transfer(alice, 200 ether);
    }

    function testVotesInitiallyZeroWithoutDelegation() public {
        assertEq(token.getVotes(alice), 0);
    }

    function testDelegationGivesVotingPower() public {
        vm.startPrank(alice);
        token.delegate(alice);
        vm.stopPrank();

        assertEq(token.getVotes(alice), 200 ether);
    }

    function testGetPastVotesSnapshot() public {
        vm.startPrank(alice);
        token.delegate(alice);
        vm.stopPrank();

        vm.roll(block.number + 1);
        uint256 snapshotBlock = block.number - 1;

        vm.startPrank(alice);
        token.transfer(bob, 50 ether);
        vm.stopPrank();

        assertEq(token.getVotes(alice), 150 ether);
        assertEq(token.getPastVotes(alice, snapshotBlock), 200 ether);
    }
}
