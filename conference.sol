//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

contract Conference { 
  address payable public organizer;
  mapping (address => uint) public registrantsPaid;
  uint public numRegistrants;
  uint public quota;
  // so you can log these events
  event Deposit(address _from, uint _amount); 
  event Refund(address _to, uint _amount);

  constructor(uint _quota) {
    organizer = msg.sender;
    quota = _quota;
    numRegistrants = 0;
  }

  function buyTicket() public payable returns (bool success) { 
    if (numRegistrants >= quota) { return false; } 
    if (msg.value >= 100) {
     registrantsPaid[msg.sender] = msg.value;
     numRegistrants++;
     emit Deposit(msg.sender, msg.value);
     return true;
    }
    emit Deposit(msg.sender, msg.value);
    return false;
  }
  function changeQuota(uint newquota) public {
    if (msg.sender != organizer) { return; }
    quota = newquota;
  }
  function refundTicket(address payable recipient, uint amount) public payable {
    if (msg.sender != organizer) { return; }
    if (registrantsPaid[recipient] == amount) {
      address myAddress = address(this);
      if (myAddress.balance >= amount) {
        recipient.transfer(amount);
        registrantsPaid[recipient] = 0;
        numRegistrants--;
        emit Refund(recipient, amount);
      }
     }
  }
  function destroy() public payable{ // so funds not locked in contract forever
    if (msg.sender == organizer) {
      selfdestruct(organizer); // send funds to organizer
    }
  }
}