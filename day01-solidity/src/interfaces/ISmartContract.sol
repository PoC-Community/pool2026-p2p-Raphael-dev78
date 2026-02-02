// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISmartContract {
    enum RoleEnum { STUDENT, TEACHER }

    struct Informations {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        RoleEnum role;
    }

    event BalanceUpdated(address indexed user, uint256 newBalance);

    error InsufficientBalance(uint256 available, uint256 requested);

    function halfAnswerOfLife() external view returns (uint256);
    function myEthereumContractAddress() external view returns (address);
    function myEthereumAddress() external view returns (address);
    function poCIsWhat() external view returns (string memory);
    function myGrades(string calldata _key) external view returns (uint256);
    function myPhoneNumber(uint256 _index) external view returns (string memory);
    function balances(address _user) external view returns (uint256);

    function myInformations()
        external
        view
        returns (
            string memory firstName,
            string memory lastName,
            uint8 age,
            string memory city,
            RoleEnum role
        );

    function myTeacher()
        external
        view
        returns (
            string memory firstName,
            string memory lastName,
            uint8 age,
            string memory city,
            RoleEnum role
        );

    function getHalfAnswerOfLife() external view returns (uint256);
    function getpoCIsWhat() external view returns (string memory);
    function editMyCity(string calldata _newCity) external;
    function getMyFullName() external view returns (string memory);
    function completeHalfAnswerOfLife() external;
    function hashMyMessage(string calldata _message) external pure returns (bytes32);
    function deposit() external payable;
    function getMyBalance() external view returns (uint256);
    function addToBalance() external payable;
    function withdrawFromBalance(uint256 _amount) external;
    function sendEth(address payable _recipient, uint256 _amount) external;
}
