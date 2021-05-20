// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

contract DMooze {

    uint256 MONTH = 86400 * 30;

    struct Project {
        address addr;
        uint256 createdTime;
        uint256 currMoney;
    }

    mapping(string => Project) public Projects;

    modifier canCreate(string memory id) {
        // project shouldn't be created already
        require(Projects[id].createdTime == 0);
        _;
    }

    modifier canSponsor(string memory id, uint256 amount) {
        // project exists && before 30 days && correct amount
        require(Projects[id].createdTime != 0, "This project doesn't exist.");
        require(Projects[id].createdTime + MONTH > block.timestamp, "This project is out of date.");
        require(msg.value == amount, "Incorrect amount of ether.");
        _;
    }

    modifier canWithdraw(string memory id, uint256 amount, string memory description) {
        // only project owner && after 30 days && has enough money in the project && non-empty description
        require(msg.sender == Projects[id].addr, "Only this project's owner can withdraw the money.");
        require(Projects[id].createdTime + MONTH < block.timestamp, "This project is still in sponsor phase.");
        require(amount <= Projects[id].currMoney, "This project doesn't have enough money.");
        require(keccak256(bytes(description)) != keccak256(""), "To withdraw money, description should be provided.");
        _;
    }

    event createEvent(address addr, string id, uint256 time);

    event sponsorEvent(address from, string to, uint256 amount);

    event withdrawEvent(string id, address to, uint256 amount, string description);

    function create(string memory id, uint256 time) canCreate(id) public {
        Projects[id] = Project(msg.sender, time, 0);
        emit createEvent(msg.sender, id, time);
    }

    function sponsor(string memory id, uint256 amount) canSponsor(id, amount) payable public {
        Projects[id].currMoney += amount;
        emit sponsorEvent(msg.sender, id, amount);
    }

    function withdraw(string memory id, uint256 amount, string memory description) canWithdraw(id, amount, description) payable public {
        msg.sender.transfer(amount);
        Projects[id].currMoney -= amount;
        emit withdrawEvent(id, msg.sender, amount, description);
    }
}