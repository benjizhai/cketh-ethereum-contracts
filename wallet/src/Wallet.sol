// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";

contract Wallet is ReentrancyGuard {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function withdraw(uint256 amount, address payable to) public onlyOwner nonReentrant {
        to.transfer(amount);
    }

    function withdrawERC20(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner nonReentrant {
        IERC20(token).transfer(to, amount);
    }

    /// End
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
