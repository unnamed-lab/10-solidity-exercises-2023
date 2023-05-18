// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Escrow {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    address public worker;
    uint private constant is_accepted = 1;
    uint private constant is_confirmed = 2;
    uint private constant is_completed = 3;
    uint private _stage;
    uint public payment;

    constructor() {
        _status = NotEntered;
        owner = msg.sender;
    }
    
    modifier nonReentrancy() {
        require(_status != Entered, "Reentrancy call");
        _status = Entered;
        _;
        _status = NotEntered;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not creator of contract");
        _;
    }

    function deposit() payable public virtual nonReentrancy onlyOwner {
        require(msg.value >= 0.01 ether, "Deposit may be too much or too little.");
        require(_stage != is_accepted && _stage != is_confirmed && _stage != is_completed, "Worker has accepted the contract.");
        payment += msg.value;
    }

    function acceptContract() public virtual nonReentrancy {
        require(msg.sender != owner, "The owner can't accept his own contract.");
        require(_stage != is_accepted && _stage != is_confirmed && _stage != is_completed, "Contract has already been accepted.");
        _stage = is_accepted;
        worker = msg.sender;
    }

    function approve() public virtual nonReentrancy onlyOwner {
        require(_stage == is_accepted && _stage != is_confirmed && _stage != is_completed, "Service has already been approved.");
        _stage = is_confirmed;
    }

    function withdraw() payable public nonReentrancy {
        require(msg.sender == worker, "Only the worker can withdraw the funds.");
        require(_stage == is_confirmed && _stage != is_completed, "Contract has already been accepted.");
        _stage = is_completed;
        address dev = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        payable(worker).transfer(payment-(payment*100/10000));
        payable(dev).transfer(payment*100/10000);
    }


}