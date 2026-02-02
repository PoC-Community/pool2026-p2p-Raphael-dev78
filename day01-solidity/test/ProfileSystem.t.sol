// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProfileSystem} from "../src/ProfileSystem.sol";

contract ProfileSystemTest is Test {
    ProfileSystem public system;
    address user1 = address(0x1);

    function setUp() public {
        system = new ProfileSystem();
    }

    function testCreateProfile() public {
        vm.startPrank(user1);
        system.createProfile("Alice");

        (string memory name, uint256 level, ProfileSystem.Role role, uint256 lastUpdated) = system.profiles(user1);
        assertEq(name, "Alice");
        assertEq(level, 1);
        assertTrue(role == ProfileSystem.Role.USER);
        assertTrue(lastUpdated > 0);
        vm.stopPrank();
    }

    function testCannotCreateEmptyProfile() public {
        vm.startPrank(user1);
        vm.expectRevert(ProfileSystem.EmptyUsername.selector);
        system.createProfile("");
        vm.stopPrank();
    }

    function testCannotCreateDuplicateProfile() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        vm.expectRevert(ProfileSystem.UserAlreadyExists.selector);
        system.createProfile("Alice");
        vm.stopPrank();
    }

    function testLevelUp() public {
        vm.startPrank(user1);
        system.createProfile("Alice");
        system.levelUp();

        (, uint256 level, , ) = system.profiles(user1);
        assertEq(level, 2);
        vm.stopPrank();
    }

    function testCannotLevelUpIfNotRegistered() public {
        vm.startPrank(user1);
        vm.expectRevert(ProfileSystem.UserNotRegistered.selector);
        system.levelUp();
        vm.stopPrank();
    }
}
