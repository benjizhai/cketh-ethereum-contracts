# cketh-ethereum-contracts
Ethereum contracts for ckETH

##Toolchain
https://github.com/foundry-rs/foundry

##Goerli deployed contract
https://goerli.etherscan.io/address/0x273792bEc87a65196eD36FcCBaD80F1661f6846F

##Deploy
```
forge create --private-key $DEVT0 src/Factory.sol:Factory
```

##Test
```
cast send $FACTORYADDR "spawn(bytes32)" $PRINCIPAL0 --private-key $DEVT0
cast send $FACTORYADDR "spawn(bytes32)" $PRINCIPAL1 --private-key $DEVT0
```