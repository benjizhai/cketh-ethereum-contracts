// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";

contract Wallet is Ownable, ReentrancyGuard {

    // ERC20 auto forwarder
    function onERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        // ERC721 auto forwarder
        IERC721(_msgSender()).safeTransferFrom(address(this), owner(), tokenId, data);
        return this.onERC721Received.selector;
    }

    function withdraw(uint256 amount) public onlyOwner nonReentrant {
        payable(owner()).transfer(amount);
    }

    function withdrawAll() public onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawERC20(address token, uint256 amount) public onlyOwner nonReentrant {
        IERC20(token).transfer(owner(), amount);
    }

    function withdrawERC721(address token, uint256 tokenId) public onlyOwner nonReentrant {
        IERC721(token).safeTransferFrom(address(this), owner(), tokenId);
    }

    // fund rescue methods verifying signature from factory.signer



}
