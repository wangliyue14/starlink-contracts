## STARLINK NFTs and Auctions

## Config

Create .env file in root directory and write following:

STLM_CONTRACT_ADDR=[fill this once you deploy]
STLM_OWNER=[fill the adress to receive the NFT]
MNEMONIC_PHRASE=[fill with your wallet phrase]


## Install

npm install

## Test

rinkeby

npx hardhat run --network rinkeby scripts/deploy_stlm.js

Deployed StlmNFT Address:  0x545f3c98f82478a1838e066d601cb4d9d41ea194

npx hardhat verify --network rinkeby 0x545f3c98f82478a1838e066d601cb4d9d41ea194


run to automate minting:

node scripts/mint_tokens.js
