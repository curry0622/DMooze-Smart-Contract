// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract HelloWorld {
    string message;
    event NewMessageEvent(string newMessage);

    constructor(string memory deployMessage) public {
        message = deployMessage;
    }

    function getMessage() public view returns (string memory) {
        return message;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
        emit NewMessageEvent(newMessage);
    }
}
