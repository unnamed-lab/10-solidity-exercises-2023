# 10 Solidity Exercises For Beginners.

Welcome to my latest project, where I've compiled a list of 10 Solidity smart contract exercises that you can try out to improve your skills in blockchain development. 

In this project, you'll find a variety of smart contract implementations, ranging from simple storage contracts to more complex systems like auctions, crowdfunding, and supply chain management. 
Each exercise is designed to challenge your understanding of Solidity and help you gain practical experience in building decentralized applications. 
Whether you're a beginner or an experienced developer, you're sure to find something that interests you in this collection. 

**So, what are you waiting for? Let's dive into the world of smart contracts and start building! 💻🚀**

Here are the exercises we would be working on:
1. Create a simple smart contract that stores a string and allows other users to read it.
2. Create a smart contract that allows users to vote on a proposal.
3. Create a smart contract that implements a simple auction system.
4. Create a smart contract that implements a basic crowdfunding system.
5. Create a smart contract that implements a simple token system.
6. Create a smart contract that implements a simple lottery system.
7. Create a smart contract that implements a simple escrow system.
8. Create a smart contract that allows users to buy and sell items using a cryptocurrency.
9. Create a smart contract that implements a basic supply chain management system.
10. Create a smart contract that implements a simple decentralized exchange.


**Solidity contract file directories(../contracts):**
1. Create a simple smart contract that stores a string and allows other users to read it.
```
..\contracts\Messaging.sol
```
2. Create a smart contract that allows users to vote on a proposal.
```
..\contracts\VotingPoll.sol
```
3. Create a smart contract that implements a simple auction system.
```
..\contracts\Auction.sol
```
4. Create a smart contract that implements a basic crowdfunding system.
```
..\contracts\Crowdfunding.sol
```
5. Create a smart contract that implements a simple token system.
```
..\contracts\SimpleToken.sol
```
6. Create a smart contract that implements a simple lottery system.
```
..\contracts\Lottery.sol
```
7. Create a smart contract that implements a simple escrow system.
```
..\contracts\Escrow.sol
```
8. Create a smart contract that allows users to buy and sell items using a cryptocurrency.
```
..\contracts\Marketplace.sol
```
9. Create a smart contract that implements a basic supply chain management system.
```
..\contracts\SupplyChain.sol
```
10. Create a smart contract that implements a simple decentralized exchange.
```
..\
```


**During this exercise, the Solidity compiler version used was the 0.8.18;**
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
```

**The non reentrancy modifier was used throughout the exercise to ensure that on some given functions the contract doesn't call itself.**
```
uint private constant NotEntered = 0;
uint private constant Entered = 1;
uint private _status;

...

modifier nonReentrancy() {
    require(_status != Entered, "Reentrancy call");
    _status = Entered;
    _;
    _status = NotEntered;
}
```

**To give the contract deployer the power to run some particular functions, I added the onlyOwner modifier.**
```
modifier onlyOwner() {
    require(msg.sender == owner, "Not creator of contract");
    _;
}
```


**Added by default:::**
Try running some of the following tasks:
```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
