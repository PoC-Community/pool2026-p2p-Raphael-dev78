// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

import {PoolToken} from "../src/PoolToken.sol";
import {Vault} from "../src/Vault.sol";

contract VaultGovernanceTest is Test {
    PoolToken private token;
    Vault private vault;

    address private alice = address(0xA11CE);
    address private bob = address(0xB0B);

    function setUp() public {
        token = new PoolToken(1_000_000 ether);
        vault = new Vault(token);

        bool ok = token.transfer(alice, 2_000 ether);
        assertTrue(ok);

        vm.startPrank(alice);
        token.approve(address(vault), 2_000 ether);
        vm.stopPrank();
    }

    function testSetWithdrawalFee() public {
        vault.setGovernor(alice);

        vm.prank(alice);
        vault.setWithdrawalFee(250);

        assertEq(vault.withdrawalFeeBps(), 250);
    }

    function testNonGovernorCannotSetFee() public {
        vault.setGovernor(alice);

        vm.prank(bob);
        vm.expectRevert(Vault.OnlyGovernor.selector);
        vault.setWithdrawalFee(250);
    }

    function testFeeCannotExceedMax() public {
        vault.setGovernor(alice);

        vm.prank(alice);
        vm.expectRevert(Vault.FeeTooHigh.selector);
        vault.setWithdrawalFee(1500);
    }

    function testWithdrawWithFee() public {
        vault.setGovernor(alice);

        vm.prank(alice);
        vault.setWithdrawalFee(250);

        vm.startPrank(alice);
        vault.deposit(1_000 ether);
        uint256 shares = vault.balances(alice);
        vault.withdraw(shares);
        vm.stopPrank();

        assertEq(token.balanceOf(alice), 1_975 ether);
        assertEq(token.balanceOf(address(vault)), 25 ether);
    }
}
