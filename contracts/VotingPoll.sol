// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Works like Reddit Upvote and Downvote system 

contract VotingPoll {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    struct Poll{
        uint id;
        string name;
        string description;
        uint upVote;
        uint downVote;
    }
    Poll public  currentPoll; // Stores the contract struct
    uint internal downvoted = 1; // Downvote value
    uint internal upvoted = 2; // Upvote value
    uint public upVotes; // Total numbers of upvotes
    uint public downVotes; // Total numbers of downvotes
    uint public totalVotes; // Total numbers of votes
    mapping (address => uint) public voted;

    constructor(string memory _name, string memory _description) {
        _status = NotEntered;
        currentPoll = Poll(block.timestamp, _name, _description, 0, 0);
     }

    modifier nonReentrancy() {
        require(_status != Entered, "Reentrancy call");
        _status = Entered;
        _;
        _status = NotEntered;
    }

    modifier notVoted() {
        require(voted[msg.sender] != downvoted && voted[msg.sender] != upvoted, "User has already voted!");
        _;
    }

    function upVote() public virtual nonReentrancy() notVoted {
        currentPoll.upVote += 1;
        upVotes++;
        totalVotes++;
        voted[msg.sender] = 2;
    }

    function downVote() public virtual nonReentrancy() notVoted {
        currentPoll.downVote += 1;
        downVotes++;
        totalVotes++;
        voted[msg.sender] = 1;
    }

}