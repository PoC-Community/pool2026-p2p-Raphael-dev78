// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Vault} from "../src/Vault.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract MaliciousToken is ERC20 {
    Vault private vault;
    address private attacker;
    uint256 private attackShares;
    bool public attackEnabled;
    bool public reenterAttempted;
    bool public reenterSucceeded;

    constructor() ERC20("Malicious Token", "MAL") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setVault(address vaultAddress) external {
        vault = Vault(vaultAddress);
    }

    function setAttack(address attackerAddress, uint256 shares) external {
        attacker = attackerAddress;
        attackShares = shares;
    }

    function enableAttack(bool enabled) external {
        attackEnabled = enabled;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _maybeReenter(to);
        return super.transfer(to, amount);
    }

    function _maybeReenter(address to) internal {
        if (!attackEnabled || to != attacker || reenterAttempted) {
            return;
        }

        reenterAttempted = true;
        try vault.withdraw(attackShares) {
            reenterSucceeded = true;
        } catch {}
    }
}

contract VaultTest is Test {
    MockERC20 private token;
    Vault private vault;

    address private alice = address(0xA11CE);

    function setUp() public {
        token = new MockERC20();
        vault = new Vault(token);

        token.mint(alice, 1_000 ether);
        token.mint(address(this), 1_000 ether);
    }

    function testAddRewardOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        vault.addReward(1 ether);
    }

    function testCannotAddRewardToEmptyVault() public {
        token.approve(address(vault), 1 ether);
        vm.expectRevert(Vault.ZeroShares.selector);
        vault.addReward(1 ether);
    }

    function testRewardsIncreaseRatioAndAssets() public {
        uint256 depositAmount = 100 ether;
        uint256 rewardAmount = 100 ether;

        vm.startPrank(alice);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount);
        vm.stopPrank();

        token.approve(address(vault), rewardAmount);
        vault.addReward(rewardAmount);

        uint256 ratio = vault.currentRatio();
        assertGt(ratio, 1e18);

        vm.startPrank(alice);
        uint256 assetsOut = vault.withdraw(shares);
        vm.stopPrank();

        assertGt(assetsOut, depositAmount);
        assertEq(token.balanceOf(alice), 1_000 ether - depositAmount + assetsOut);
    }

    function testWithdrawBlocksReentrancy() public {
        MaliciousToken malicious = new MaliciousToken();
        Vault maliciousVault = new Vault(malicious);
        malicious.setVault(address(maliciousVault));

        address attacker = address(0xBEEF);
        uint256 depositAmount = 100 ether;

        malicious.mint(attacker, depositAmount);

        vm.startPrank(attacker);
        malicious.approve(address(maliciousVault), depositAmount);
        uint256 shares = maliciousVault.deposit(depositAmount);
        vm.stopPrank();

        malicious.setAttack(attacker, shares);
        malicious.enableAttack(true);

        vm.startPrank(attacker);
        uint256 assetsOut = maliciousVault.withdraw(shares);
        vm.stopPrank();

        assertEq(assetsOut, depositAmount);
        assertEq(malicious.balanceOf(attacker), depositAmount);
        assertTrue(malicious.reenterAttempted());
        assertFalse(malicious.reenterSucceeded());
    }
}
