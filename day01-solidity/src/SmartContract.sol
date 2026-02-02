// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartContract {

    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public PoCIsWhat = "PoC is good, PoC is life.";

    bool internal _areYouABadPerson = false;

    int256 private _youAreACheater = -42;
}
