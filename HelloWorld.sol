//SPDX-License-Identifier: Unlicense

pragma solidity ^0.7.0;

contract hello { 
    string greeting;  
    function greeter(string memory _greeting) public {
        greeting = _greeting;
    } 
    function greet() view public returns (string memory) {
        return greeting;
    }
}