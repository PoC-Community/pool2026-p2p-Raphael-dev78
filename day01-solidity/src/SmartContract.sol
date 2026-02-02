// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartContract {

    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public poCIsWhat = "PoC is good, PoC is life.";
 
    bool internal _areYouABadPerson = false;

    int256 private _youAreACheater = -42;

    bytes32 whoIsTheBest;
    mapping(string => uint256) public myGrades;
    string[5] public myPhoneNumber;

    enum RoleEnum { STUDENT, TEACHER }

    struct Informations {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        RoleEnum role;
    }

    Informations public myInformations = Informations({
        firstName: "Raphael",
        lastName: "Unknown",
        age: 25,
        city: "Paris",
        role: RoleEnum.STUDENT
    });

    Informations public myTeacher = Informations({
        firstName: "Alice",
        lastName: "Wonderland",
        age: 30,
        city: "London",
        role: RoleEnum.TEACHER
    });

    /**
     * @notice Returns halfAnswerOfLife
     */
    function getHalfAnswerOfLife() public view returns (uint256) {
        return halfAnswerOfLife;
    }

    /**
     * @notice Returns the contract address (internal)
     */
    function _getMyEthereumContractAddress() internal view returns (address) {
        return myEthereumContractAddress;
    }

    /**
     * @notice Returns PoCIsWhat (external only)
     */
    function getpoCIsWhat() external view returns (string memory) {
        return poCIsWhat;
    }

    /**
     * @notice Sets _areYouABadPerson (internal)
     */
    function _setAreYouABadPerson(bool _value) internal {
        _areYouABadPerson = _value;
    }

    /**
     * @notice Updates myInformations.city
     */
    function editMyCity(string calldata _newCity) public {
        myInformations.city = _newCity;
    }

    /**
     * @notice Returns full name
     */
    function getMyFullName() public view returns (string memory) {
        return string(abi.encodePacked(myInformations.firstName, " ", myInformations.lastName));
    }
}