// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Auction {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    struct Item {
        uint timestamp;
        string name;
        string description;
        uint marketValue;
        uint bidValue;
    }
    Item public AuctionItem;
    uint public totalBid;
    uint internal recentBid;
    uint public finalBid;
    address internal recentBidder;


    constructor(string memory _name, string memory _description, uint _amountInETH) {
        _status = NotEntered;
        owner = msg.sender;
        AuctionItem = Item(block.timestamp, _name, _description, _amountInETH * (10**18), 0);
        recentBid = 0 wei;
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

    function _addBid() private {
        if (recentBidder == address(0)) {
            recentBidder = msg.sender;
            recentBid = msg.value;
        } else 
        {
            payable(recentBidder).transfer(recentBid);
            recentBidder = msg.sender;
            recentBid = msg.value;
        }
        AuctionItem.bidValue = recentBid;
        totalBid += msg.value;
    }

    function placeBid() payable public virtual nonReentrancy {
        if (recentBid > 0) {
            require(msg.value > recentBid, "Place a bigger bid.");
            _addBid();
        } else 
        {
            _addBid();
        }
    }

    function highestBidder() public view returns (address) {
        return recentBidder;
    }
    
    function highestBid() public view returns (uint) {
        return recentBid;
    }
    
    function rewardHighestBid() public payable nonReentrancy onlyOwner {
        payable(owner).transfer(highestBid());
        finalBid = recentBid;
        recentBid = 0;
    }

}