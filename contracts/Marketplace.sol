// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Marketplace {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    struct Item {
        bytes32 uniqueID;
        address authorID;
        string name;
        string description;
        uint price;
    }
    Item internal goodsItem;
    mapping (uint => Item) private itemID;
    mapping (address => mapping (bytes32 => uint)) private userItems;
    Item[] public marketItems;

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

    function createItem(string memory _name, string memory _description, uint _priceInETHUnit) public nonReentrancy onlyOwner {
        goodsItem = Item(keccak256(abi.encodePacked(_name)), msg.sender,_name, _description, _priceInETHUnit * 10**15);
        marketItems.push(goodsItem);
        for(uint i = 0; i < marketItems.length; i++) {
            itemID[i] = goodsItem;
        }
    }

    function findItemPrice(uint _itemID) public virtual view returns (uint) {
        return itemID[_itemID].price;
    }

    function buyItem(uint _itemID) payable public nonReentrancy {
        require(msg.value >= itemID[_itemID].price, "Insufficient balance.");
        uint deposit = msg.value;
        if (deposit == itemID[_itemID].price) {
            payable(itemID[_itemID].authorID).transfer(deposit);
        } 
        else if(deposit > itemID[_itemID].price) {
            payable(itemID[_itemID].authorID).transfer(itemID[_itemID].price);
            payable(msg.sender).transfer(deposit - itemID[_itemID].price);
        }
        userItems[msg.sender][itemID[_itemID].uniqueID] += 1;
    }

    function findItemOwned(uint _itemID) public virtual view returns (uint) {
        return userItems[msg.sender][itemID[_itemID].uniqueID];
    }
}