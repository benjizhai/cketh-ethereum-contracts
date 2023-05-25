// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/proxy/Clones.sol";
import "../../wallet/src/Wallet.sol";

contract Factory is Ownable {
    address _walletImplementation;
    mapping (bytes32 => address) _wallets;
    bytes32[] _principalsList;

    event Spawned(bytes32 principal, address addr);

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

    function collectETH(Wallet[] calldata wallets, uint256[] calldata amounts) external onlyOwner {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdraw(amounts[i]);
        }
    }

    function collectERC20(address token, Wallet[] calldata wallets, uint256[] calldata amounts) external onlyOwner {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdrawERC20(token, amounts[i]);
        }
    }

    function collectERC721(address token, Wallet[] calldata wallets, uint256[] calldata tokenids) external onlyOwner {
        require(wallets.length == tokenids.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdrawERC721(token, tokenids[i]);
        }
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
