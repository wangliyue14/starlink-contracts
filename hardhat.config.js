require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.6.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: "https://mainnet.infura.io/v3/3849a711ff6443d0b44b62f4156c7c0a",
      },
      chainId: 1337,
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/3849a711ff6443d0b44b62f4156c7c0a",
      accounts: [
        process.env.PRIVATE_KEY,
      ],
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/3849a711ff6443d0b44b62f4156c7c0a",
      accounts: [
        process.env.PRIVATE_KEY,
      ],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
