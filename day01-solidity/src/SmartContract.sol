// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartContract {
    address private owner;
    uint256 public halfAnswerOfLife = 21;
    address public myEthereumContractAddress = address(this);
    address public myEthereumAddress = msg.sender;
    string public poCIsWhat = "PoC is good, PoC is life.";
 
    bool internal _areYouABadPerson = false;

    int256 private _youAreACheater = -42;

    bytes32 whoIsTheBest;
    mapping(string => uint256) public myGrades;
    string[5] public myPhoneNumber;
    mapping(address => uint256) public balances;

    event BalanceUpdated(address indexed user, uint256 newBalance);
    error InsufficientBalance(uint256 available, uint256 requested);

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

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Not the owner");
    }

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

    function completeHalfAnswerOfLife() public onlyOwner {
        halfAnswerOfLife += 21;
    }

    /**
     * @notice Returns keccak256 hash of a message
     */
    function hashMyMessage(string calldata _message) public pure returns (bytes32) {
        bytes32 result;
        assembly {
            let len := calldataload(_message.offset)
            let ptr := mload(0x40)
            calldatacopy(ptr, add(_message.offset, 0x20), len)
            result := keccak256(ptr, len)
            mstore(0x40, add(ptr, and(add(len, 0x3f), not(0x1f))))
        }
        return result;
    }

    /**
     * @notice Accepts ETH deposits
     */
    function deposit() public payable {
        // msg.value contains the amount of ETH sent
    }

    /**
     * @notice Returns the caller balance
     */
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @notice Adds msg.value to caller balance
     */
    function addToBalance() public payable {
        balances[msg.sender] += msg.value;
        emit BalanceUpdated(msg.sender, balances[msg.sender]);
    }

    /**
     * @notice Withdraws ETH from caller balance
     */
    function withdrawFromBalance(uint256 _amount) public {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance(balances[msg.sender], _amount);
        }
        balances[msg.sender] -= _amount;
        emit BalanceUpdated(msg.sender, balances[msg.sender]);
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Sends ETH to a recipient
     */
    function sendEth(address payable _recipient, uint256 _amount) public onlyOwner {
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Transfer failed");
    }
}