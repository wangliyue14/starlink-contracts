// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const SateAuction = await hre.ethers.getContractFactory("SateAuction");
  const sateAuction = await SateAuction.deploy(
    "0x9da1E70E26156abC3B29260Df67d2aB65D761Ad6",
    "0x5a168798df2b9d84e28958702156b036927a9e29",
    "0x42eD619fdb869d411f9e10BEFD2df4e3460c280F",
    "0x4C21De8A36fB3A6e18944047EF060492a77db79f"
  );

  await sateAuction.deployed();

  console.log("SateAuction:", sateAuction.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
