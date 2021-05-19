// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

contract DMooze {

    uint256 MONTH = 86400 * 30;

    struct Project {
        address addr;
        uint256 createdTime;
        uint256 currMoney;
    }

    mapping(uint256 => Project) public Projects;

    modifier newProject(uint256 id) {
        require(Projects[id].createdTime == 0);
        _;
    }

    modifier canSponsor(uint256 id, uint256 amount) {
        // project exists && before 30 days && correct amount
        require(Projects[id].createdTime != 0, "This project doesn't exist.");
        require(Projects[id].createdTime + MONTH > block.timestamp, "This project is out of date.");
        require(msg.value == amount, "Incorrect amount of ether.");
        _;
    }

    modifier canWithdraw(uint256 id, uint256 amount) {
        // only project owner && after 30 days && has enough money in the project && correct amount
        require(msg.sender == Projects[id].addr, "Only this project's owner can withdraw the money.");
        require(Projects[id].createdTime + MONTH < block.timestamp, "This project is still in sponsor phase.");
        require(amount <= Projects[id].currMoney, "This project doesn't have enough money.");
        require(msg.value == amount, "Incorrect amount of ether.");
        _;
    }

    event createProjectEvent(address addr, uint256 id, uint256 time);

    event sponsorEvent(address from, uint256 to, uint256 amount);

    event withdrawEvent(uint256 id, address to, uint256 amount);

    function createProject(uint256 id, uint256 time) newProject(id) public {
        Projects[id] = Project(msg.sender, time, 0);
        emit createProjectEvent(msg.sender, id, time);
    }

    function sponsor(uint256 id, uint256 amount) canSponsor(id, amount) payable public {
        Projects[id].currMoney += amount;
        emit sponsorEvent(msg.sender, id, amount);
    }

    function withdraw(uint256 id, uint256 amount) canWithdraw(id, amount) payable public {
        address payable sender = address(uint160(msg.sender));
        sender.transfer(amount);
        emit withdrawEvent(id, msg.sender, amount);
    }
}