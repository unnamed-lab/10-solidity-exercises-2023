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
    }
    Item public AuctionItem;
    uint public totalBid;
    uint internal recentBid;
    address internal recentBidder;
    address[] public bidders;
    mapping (address => uint) public bidderFunds;


    constructor(string memory _name, string memory _description, uint _amountInETH) {
        _status = NotEntered;
        owner = msg.sender;
        AuctionItem = Item(block.timestamp, _name, _description, _amountInETH * (10**18));
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
        bidderFunds[msg.sender] += msg.value;
        recentBid = bidderFunds[msg.sender];
        recentBidder = msg.sender;
        totalBid += msg.value;

        for (uint i = 0; i < bidders.length; i++) {
            if(msg.sender != bidders[i]) {
                bidders.push(msg.sender);
            }
        }
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
        for (uint i = 0; i < bidders.length; i++) {
            if (bidders[i] != recentBidder) {
                uint refund = bidderFunds[bidders[i]];
                payable(bidders[i]).transfer(refund);
            } else 
            {
                payable(owner).transfer(highestBid());
            }    
        }
        recentBid = 0;
    }

}