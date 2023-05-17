// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract BasicMessage {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    string textMessage;
    constructor() {_status = NotEntered;}
    modifier nonReentrancy() {
        require(_status != Entered, "Reentrancy call");
        _status = Entered;
        _;
        _status = NotEntered;

    }
    event NewMessage ( uint indexed date, string message );
    function viewMessage() public view returns(string memory) { return textMessage; }
    function sendMessage(string memory _textMessage) public virtual nonReentrancy {
        textMessage = _textMessage;
        emit NewMessage(block.timestamp, textMessage);
    }
}

contract AdvancedMessage {
    uint private constant NotEntered = 0;
    uint private constant Entered = 1;
    uint private _status;
    uint public  messageID;
    mapping (address => mapping (uint => string)) public messageInbox;
    string[] inboxMessage;

    constructor() {_status = NotEntered;}
    modifier nonReentrancy() {
        require(_status != Entered, "Reentrancy call");
        _status = Entered;
        _;
        _status = NotEntered;
    }

    function sendMessage(string calldata _textMessage) public virtual nonReentrancy {
        inboxMessage.push(_textMessage);
        messageInbox[msg.sender][messageID] = _textMessage;
        messageID++;
    }

}
