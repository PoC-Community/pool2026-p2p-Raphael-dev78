// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProfileSystem {
    enum Role { GUEST, USER, ADMIN }

    struct UserProfile {
        string username;
        uint256 level;
        Role role;
        uint256 lastUpdated;
    }

    mapping(address => UserProfile) public profiles;

    error UserAlreadyExists();
    error EmptyUsername();
    error UserNotRegistered();
}
