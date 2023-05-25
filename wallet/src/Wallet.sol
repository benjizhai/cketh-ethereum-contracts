// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Wallet {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function withdraw(uint256 amount, address payable to) public onlyOwner {
        to.transfer(amount);
    }

    function withdrawERC20(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
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
