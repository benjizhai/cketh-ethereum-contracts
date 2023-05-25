// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
        wallet.setNumber(0);
    }

    function testIncrement() public {
        wallet.increment();
        assertEq(wallet.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        wallet.setNumber(x);
        assertEq(wallet.number(), x);
    }
}
