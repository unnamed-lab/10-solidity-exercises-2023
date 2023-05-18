// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    address[] public participant;
    mapping (address => bool) is_participant;
    uint public lotteryPool;
    uint public deadline;
    address public winnerAddress;

    constructor(uint _deadline) {
        _status = NotEntered;
        owner = msg.sender;
        deadline = block.timestamp + _deadline;
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

    function deposit() payable public virtual nonReentrancy {
        require(msg.value >= 0.01 ether, "Deposit may be too much or too little.");
        if(is_participant[msg.sender] == false) {
            is_participant[msg.sender] = true;
            lotteryPool += msg.value;
            participant.push(msg.sender);
        } 
        else {
            revert("User has participated on lottery!");
        }
    }

    function timestamp() public virtual view returns (uint) {
        return block.timestamp;
    }

    function randomNumber(uint _num) internal  virtual view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % _num;
    }

    function selectWinner() payable public nonReentrancy onlyOwner {
        require(block.timestamp >= deadline, "Lottery end time has not reached.");
        uint rand = randomNumber(participant.length);
        payable(participant[rand]).transfer(lotteryPool-(lotteryPool*1000/10000));
        payable(owner).transfer(lotteryPool*1000/10000);
        lotteryPool = 0;
        winnerAddress = participant[rand];
    }

}