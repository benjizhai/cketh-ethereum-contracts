// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/proxy/Clones.sol";
import "src/Wallet.sol";

contract Factory is Ownable, ReentrancyGuard {
    address _walletImplementation;
    mapping (bytes32 => address) _wallets;
    bytes32[] _principalsList;

    event Spawned(bytes32 principal, address addr);
    event CollectedETH(Wallet[] wallets, uint256[] amounts);
    event CollectedERC20(address token, Wallet[] wallets, uint256[] amounts);
    event CollectedERC721(address token, Wallet[] wallets, uint256[] tokenids);
    event SentETH(address[] wallets, uint256[] amounts);
    event SentERC20(address token, address[] wallets, uint256[] amounts);
    event SentERC721(address token, address[] wallets, uint256[] tokenids);

    constructor() {
        _walletImplementation = address(new Wallet());
    }

    // Anyone can spawn a wallet for a principal
    function spawn(bytes32 principal) external returns (address addr) {
        addr = Clones.cloneDeterministic(_walletImplementation, principal);
        _wallets[principal] = addr;
        _principalsList.push(principal);
        emit Spawned(principal, addr);
    }

    function collectETH(Wallet[] calldata wallets, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdraw(amounts[i]);
        }
        emit CollectedETH(wallets, amounts);
    }

    function collectERC20(address token, Wallet[] calldata wallets, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdrawERC20(token, amounts[i]);
        }
        emit CollectedERC20(token, wallets, amounts);
    }

    function collectERC721(address token, Wallet[] calldata wallets, uint256[] calldata tokenids) external onlyOwner nonReentrant {
        require(wallets.length == tokenids.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdrawERC721(token, tokenids[i]);
        }
        emit CollectedERC721(token, wallets, tokenids);
    }

    function sendETH(address[] calldata wallets, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(amounts[i]);
        }
        emit SentETH(wallets, amounts);
    }

    function sendERC20(address token, address[] calldata wallets, uint256[] calldata amounts) external onlyOwner nonReentrant {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            IERC20(token).transfer(wallets[i], amounts[i]);
        }
        emit SentERC20(token, wallets, amounts);
    }

    function sendERC721(address token, address[] calldata wallets, uint256[] calldata tokenids) external onlyOwner nonReentrant {
        require(wallets.length == tokenids.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            IERC721(token).safeTransferFrom(address(this), wallets[i], tokenids[i]);
        }
        emit SentERC721(token, wallets, tokenids);
    }

    function computeAddress(bytes32 principal) external view returns (address addr) {
        addr = Clones.predictDeterministicAddress(_walletImplementation, principal);
    }

    function walletExists(bytes32 principal) external view returns (bool) {
        return _wallets[principal] != address(0);
    }

    function principalsList() external view returns (bytes32[] memory) {
        return _principalsList;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

}
