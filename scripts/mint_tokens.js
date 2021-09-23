const Web3 = require('web3');
const HDWalletProvider = require("@truffle/hdwallet-provider");
const stlmAbi = require("../abis/StlmNFT.json");
const dotenv = require("dotenv")
dotenv.config()

const mnemonicPhrase = process.env.MNEMONIC_PHRASE;

let provider = new HDWalletProvider({
    mnemonic: {
      phrase: mnemonicPhrase
    },
    providerOrUrl: "https://rinkeby.infura.io/v3/315b5370f81c47ef9ec8dc3529c05175"
});

const web3 = new Web3(provider)

const contractAddr = process.env.STLM_CONTRACT_ADDR
const stlmNftContract = new web3.eth.Contract(stlmAbi, contractAddr)
const metaDataUris = ["https://starlink.mypinata.cloud/ipfs/QmSmV6ezZgN8Ay9xnt8ozvLGNGjeoRnxwvUnmvbBkgPhJ4"]
const owners = [process.env.STLM_OWNER]
stlmNftContract.methods.batchMint(owners, metaDataUris).send({
    from: process.env.STLM_OWNER
}, function(err) {
    console.log(err)
}).on('transactionHash', function(hash) {
    console.log(hash)
}).on('confirmation', function(confirmationNumber, receipt){
    console.log("confirmationNumber: " + confirmationNumber)
    if (confirmationNumber > 0) {
        process.exit()
    }
}).on('receipt', function(receipt) {
    console.log(receipt)
}).on('error', function(error, receipt) {
    console.log(error)
})
