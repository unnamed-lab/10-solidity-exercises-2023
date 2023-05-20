// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract SimpleToken is ERC20Capped, ERC20Burnable, ReentrancyGuard, AccessControl {
    address payable private owner;

    constructor(string memory _name, string memory _symbol, uint256 totalSupply)  
    ERC20(_name, _symbol) 
    ERC20Capped(totalSupply * (10 ** decimals()))
    {
        owner = payable(msg.sender);
        _mint(owner, totalSupply * (10 ** decimals())); 
    }

    // Events 
    event NewTx (uint indexed date, address indexed from, address indexed to, uint amount);
    event OwnershipTransfer( uint indexed date, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require (msg.sender == owner, 'You are not the owner');
        _;
    }

    // Functions
    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) onlyOwner() nonReentrant {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
    //  Contract ownership Settings
    function renounceOwnership() public virtual nonReentrant onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        owner = payable(address(0));
        emit OwnershipTransfer(block.timestamp, owner); 
    }
    function transferOwnership(address payable _newOwnerAddress) public virtual onlyOwner nonReentrant {
        owner = payable(_newOwnerAddress);
        emit OwnershipTransfer(block.timestamp, owner); 
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override(ERC20) nonReentrant {
        require(balanceOf(sender) >= amount, "ERC20: transfer amount exceeds balance"); 
        super._transfer(sender, recipient, amount);
        emit NewTx(block.timestamp, sender, recipient, amount);
    }
}
