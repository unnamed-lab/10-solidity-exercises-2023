// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SupplyChain {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    uint private smallUnit = 1 * 10**15;
    address private owner;
    address[] public distributor;
    address[] public retailer;
    mapping (address => bool) internal is_distributor;
    mapping (address => bool) internal is_retailer;
    mapping (address => uint) price;
    struct Item {
        bytes32 uniqueID;
        address manufacturerID;
        string name;
        string description;
        uint price;
        uint totalSupply;
        uint availableSupply;
    }
    Item public goods;
    mapping (address => mapping (bytes32 => uint)) private userItems;

    constructor(string memory _name, string memory _description, uint _priceInETHUnit, uint _supply) {
        _status = NotEntered;
        owner = msg.sender;
        bytes32 hashID = keccak256(abi.encodePacked(_name));
        goods = Item(hashID, owner,_name, _description, _priceInETHUnit * smallUnit, _supply, _supply);
        userItems[owner][hashID] = _supply;
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

    event UpdateAddress (uint indexed date, address indexed newAddress, string notes);

    function addDistributor(address _distributorAddr) public nonReentrancy onlyOwner{
        distributor.push(_distributorAddr);
        is_distributor[_distributorAddr] = true;
        emit UpdateAddress(block.timestamp, _distributorAddr, "New distributor wallet added.");
    }

    function addRetailer(address _retailerAddr) public nonReentrancy {
        require(is_distributor[msg.sender] == true, "You are not a distributor.");
        retailer.push(_retailerAddr);
        is_retailer[_retailerAddr] = true;
        emit UpdateAddress(block.timestamp, _retailerAddr, "New retailer wallet added.");
    }

    function addDistributorPrice(uint _amount) public virtual nonReentrancy {
        require(is_distributor[msg.sender] == true, "You are not a distributor.");
        require(userItems[msg.sender][goods.uniqueID] >= 1, "Don't have any goods in stock.");
        price[msg.sender] = _amount * smallUnit;
    }

    function addRetailPrice(uint _amount) public virtual nonReentrancy {
        require(is_retailer[msg.sender] == true, "You are not a retailer.");
        require(userItems[msg.sender][goods.uniqueID] >= 1, "Don't have any goods in stock.");
        price[msg.sender] = _amount * smallUnit;
    }

    function checkStock() public view returns (uint) {
        return userItems[msg.sender][goods.uniqueID];
    }

    function buyFromManufacturer(uint _amount) payable public nonReentrancy {
        require(is_distributor[msg.sender] == true, "Address owner is not a distributor.");
        require(msg.value >= goods.price, "Insufficient balance.");
        uint sellingPrice = goods.price;
        uint deposit = msg.value;
        if (deposit == sellingPrice * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[goods.manufacturerID][goods.uniqueID] -= _amount;
            payable(goods.manufacturerID).transfer(deposit);
        } 
        else if(deposit > sellingPrice * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[goods.manufacturerID][goods.uniqueID] -= _amount;
            payable(goods.manufacturerID).transfer(sellingPrice * _amount);
            payable(msg.sender).transfer(deposit - (sellingPrice * _amount));
        } else 
        {
            revert("Insufficient funds to buy the required amount.");
        }
    }

    function buyFromDistributor(address __distributor, uint _amount) payable public nonReentrancy {
        require(is_retailer[msg.sender] == true, "You are not a retailer.");
        require(is_distributor[__distributor] == true, "Address owner is not a distributor.");
        require(msg.value >= price[__distributor], "Insufficient balance.");
        uint deposit = msg.value;
        if (price[__distributor] == 0) {
            price[__distributor] = goods.price;
        }
        if (deposit == price[__distributor] * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[__distributor][goods.uniqueID] -= _amount;
            payable(__distributor).transfer(deposit);
        } 
        else if(deposit > price[__distributor] * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[__distributor][goods.uniqueID] -= _amount;
            payable(__distributor).transfer(price[__distributor] * _amount);
            payable(msg.sender).transfer(deposit - (price[__distributor] * _amount));
        } else 
        {
            revert("Insufficient funds to buy the required amount.");
        }
    }

    function buyProduct(address __retailer, uint _amount) payable public  nonReentrancy {
        require(is_retailer[__retailer] == true, "Address owner is not a retailer.");
        require(msg.value >= price[__retailer], "Insufficient balance.");
        uint deposit = msg.value;
        if (price[__retailer] == 0) {
            price[__retailer] = goods.price;
        }
        if (deposit == price[__retailer] * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[__retailer][goods.uniqueID] -= _amount;
            payable(__retailer).transfer(deposit);
        } 
        else if(deposit > price[__retailer] * _amount) {
            userItems[msg.sender][goods.uniqueID] += _amount;
            userItems[__retailer][goods.uniqueID] -= _amount;
            payable(__retailer).transfer(price[__retailer] * _amount);
            payable(msg.sender).transfer(deposit - (price[__retailer] * _amount));
        } else 
        {
            revert("Insufficient funds to buy the required amount.");
        }
    }

}