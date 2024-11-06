// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

interface IGreet {
    function greet(uint id) external returns (string memory);
}

contract TAGreetingCaller {
    address constant TA_CONTRACT = 0x2098383f2869664C3611143b09eC0f40c938c3ef;
    IGreet greetContract;
    
    constructor() {
        greetContract = IGreet(TA_CONTRACT);
    }
    
    function callGreet(uint id) public returns (string memory) {
        return greetContract.greet(id);
    }
}