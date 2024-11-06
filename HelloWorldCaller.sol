// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

interface IHello {
    function greet() external view returns (string memory);
    function greeter(string memory _greeting) external;
}

contract HelloCaller {
    IHello helloContract;
    
    constructor(address _helloAddress) {
        helloContract = IHello(_helloAddress);
    }
    
    function callGreet() public view returns (string memory) {
        return helloContract.greet();
    }
    
    function callGreeter(string memory _greeting) public {
        helloContract.greeter(_greeting);
    }
}