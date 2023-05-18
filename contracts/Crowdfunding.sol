// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract CrowdFunding {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    address private owner;
    struct Charity {
        uint timestamp;
        string name;
        string description;
        address recipient;
        uint donationTarget;
        uint donationRaised;
    }
    Charity public charityEvent;
    uint internal currentDonation;

    constructor(string memory _name, string memory _description, address _recipient, uint _amountInETH) {
        _status = NotEntered;
        owner = msg.sender;
        charityEvent = Charity(block.timestamp, _name, _description, _recipient, _amountInETH *(10**18), 0);
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

    function donationTarget() public virtual view returns (uint) {
        return charityEvent.donationTarget;
    }

    function donationRaised() public virtual view returns (uint) {
        return charityEvent.donationRaised;
    }

    function donate() payable public virtual {
        if (msg.value >= 1*(10**14)) {
            currentDonation += msg.value;
            charityEvent.donationRaised += msg.value;
        }
        else {
            revert("Low donation.");
        }
    }

    function withdrawDonation() payable public virtual nonReentrancy onlyOwner {
        if(donationRaised() >= donationTarget()) {
            payable(charityEvent.recipient).transfer(currentDonation-(currentDonation*100/10000));
            payable(owner).transfer(currentDonation*100/10000);
            currentDonation -= currentDonation;
            charityEvent.donationRaised -= currentDonation;

        } else {
            revert("Target not reached!");
        }
    }

    function forcedWithdrawal() payable public virtual nonReentrancy onlyOwner {
        payable(charityEvent.recipient).transfer(currentDonation-(currentDonation*1000/10000));
        payable(owner).transfer(currentDonation*1000/10000);
        currentDonation -= currentDonation;
        charityEvent.donationRaised -= currentDonation;
    }

}