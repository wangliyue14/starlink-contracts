## STARLINK NFTs and Auctions

## Install

## Test

rinkeby
npx hardhat run --network rinkeby scripts/deploy_lm_nft.js
npx hardhat run --network rinkeby scripts/deploy_lm_auction.js

StlmNFT: 0xaEDd1fb4a1E1b3Ab201921D3e4FBE869D4A5988F
StlmAuction: 0xf043250B8Ff43D2A7fe616fc64A4671159583094

npx hardhat verify --network rinkeby 0xaEDd1fb4a1E1b3Ab201921D3e4FBE869D4A5988F --constructor-args scripts/deploy_lm_arguments.js
npx hardhat verify --network rinkeby 0xf043250B8Ff43D2A7fe616fc64A4671159583094 --constructor-args scripts/deploy_lm_auction_arguments.js