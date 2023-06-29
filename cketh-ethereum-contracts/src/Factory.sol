// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/proxy/Clones.sol";
import "src/Wallet.sol";

contract Factory is Ownable, ReentrancyGuard {
    address _walletImplementation;
    mapping (address => uint256) _fees; // fees for each token, eth is 0xee
    address public signer; // tECDSA signer to release funds
    // mapping (bytes32 => address) _wallets;
    // bytes32[] _principalsList;

    event FeeSet(address indexed token, uint256 amount);
    event SignerChanged(address indexed signer);
    event Registered(bytes32 indexed principal, address indexed sender, uint256 amount);
    event Spawned(bytes32 indexed principal, address indexed addr);
    event CollectedETH(Wallet[] wallets, uint256[] amounts);
    event CollectedERC20(address indexed token, Wallet[] wallets, uint256[] amounts);
    event CollectedERC721(address indexed token, Wallet[] wallets, uint256[] tokenids);
    event SentETH(address[] wallets, uint256[] amounts);
    event SentERC20(address indexed token, address[] wallets, uint256[] amounts);
    event SentERC721(address indexed token, address[] wallets, uint256[] tokenids);
    event FeeReleasedETH(address indexed token, bytes32 indexed feeRecipient, uint256 amount);
    event FeeReleasedERC20(bytes32 indexed feeRecipient, uint256 amount);

    constructor() {
        _walletImplementation = address(new Wallet());
    }

    // Receive ETH
    // TODO: verify gas
    receive() external payable {
    }

    function setFees(address token, uint256 amount) external onlyOwner {
        _fees[token] = amount;
        emit FeeSet(token, amount);
    }

    // signer can sign a message to release funds from user wallets
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
        emit SignerChanged(_signer);
    }

    function register(bytes32 principal) external payable {
        emit Registered(principal, _msgSender(), msg.value);
    }

    // Anyone can spawn a wallet for a principal
    function spawn(bytes32 principal) public returns (address addr) {
        addr = Clones.cloneDeterministic(_walletImplementation, principal);
        // _wallets[principal] = addr;
        // _principalsList.push(principal);
        emit Spawned(principal, addr);
    }

    // Anyone can collect funds and get fees in ckETH/ckERC20
    function collectETH(Wallet[] calldata wallets, bytes32[] calldata principals, bytes32 feeRecipient) external nonReentrant {
        require(wallets.length + principals.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) { // TODO: check amount > fees
            wallets[i].withdraw(amounts[i]); // TODO: check call results and emit events accordingly
        }
        for (uint256 i = 0; i < principals.length; i++) {
            address addr = principals[i].spawn(amounts[wallets.length + i]); // TODO: check call results and emit events accordingly
            addr.withdraw(amounts[wallets.length + i]); // TODO: check call results and emit events accordingly
        }
        emit CollectedETH(wallets, amounts);
    }

    function collectERC20(address token, Wallet[] calldata wallets, uint256[] calldata amounts) external nonReentrant {
        require(wallets.length == amounts.length, "Factory: input length mismatch");
        for (uint256 i = 0; i < wallets.length; i++) {
            wallets[i].withdrawERC20(token, amounts[i]);
        }
        emit CollectedERC20(token, wallets, amounts);
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
        address addr = computeAddress(principal);
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    // function principalsList() external view returns (bytes32[] memory) {
    //     return _principalsList;
    // }

    // ERC721 receiver
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {  
        return this.onERC721Received.selector;
    }

}
