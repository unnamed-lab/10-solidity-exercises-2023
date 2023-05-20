// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/Token.sol";

contract Exchange {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    address public tokenAddress;
    uint public rate = 1 * (10**15);
    

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

    function setToken(address _tokenAddr) external virtual  {
        tokenAddress = _tokenAddr;
    }

    function tranferToken(address _recipient, uint _amount) external virtual  {
        SimpleToken token = SimpleToken(tokenAddress);
        token.transfer(_recipient, _amount);
    }

    function tokenBalance() external view  returns (uint) {
        SimpleToken token = SimpleToken(tokenAddress);
        return token.balanceOf(address(this));
    }

    function buyToken(uint _amount) payable external nonReentrancy {
        SimpleToken token = SimpleToken(tokenAddress);
        uint tokenValue = _amount * rate;
        require(msg.value >= tokenValue, "No enough ETH to complete transaction");
        // token.transfer(msg.sender, _amount);
        if (msg.value == tokenValue) {
            token.transfer(msg.sender, _amount);
        } 
        else if(msg.value > tokenValue) {
            token.transfer(msg.sender, _amount);
            payable(msg.sender).transfer(msg.value - tokenValue);
        } else 
        {
            revert("Insufficient funds to buy the required amount.");
        }      
    }

    function sellToken(uint _amount) payable external nonReentrancy {
        SimpleToken token = SimpleToken(tokenAddress);
        uint tokenValue = _amount * rate;
        uint contractBalance = address(this).balance;
        token.increaseAllowance(address(this), token.cap()); // Manually increase the allowance if this doesn't work
        token.approve(address(this), _amount);

        if (contractBalance == tokenValue) {
            token.transferFrom(msg.sender, address(this), _amount);
            payable(msg.sender).transfer(tokenValue);  
        } 
        else if(contractBalance > tokenValue) {
            token.transferFrom(msg.sender, address(this), _amount);
            payable(msg.sender).transfer(tokenValue);
        } else 
        {
            revert("Insufficient funds to sell the required amount.");
        }      
        
    }

}
