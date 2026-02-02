// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SmartContract.sol";

contract SmartContractHelper is SmartContract {
    // Expose internal functions/variables as public for testing
    function getAreYouABadPerson() public view returns (bool) {
        return _areYouABadPerson;
    }
}

contract SmartContractTest is Test {
    SmartContractHelper public myContract;

    function setUp() public {
        myContract = new SmartContractHelper();
    }

    function testHalfAnswerOfLife() public view {
        assertEq(myContract.getHalfAnswerOfLife(), 21);
    }

    function testAreYouABadPerson() public view {
        assertEq(myContract.getAreYouABadPerson(), false);
    }

    function testStructData() public view {
        (
            string memory firstName, 
            string memory lastName, 
            uint8 age, 
            string memory city, 
            SmartContract.RoleEnum role
        ) = myContract.myInformations();

        assertEq(firstName, "Raphael");
        assertEq(lastName, "Unknown");
        assertEq(age, 25);
        assertEq(city, "Paris");
        // Enum value STUDENT should correspond to 0
        assertTrue(role == SmartContract.RoleEnum.STUDENT);
    }
}
