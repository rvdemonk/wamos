const hre = require("hardhat");

async function main() {
  const [account] = await hre.ethers.getSigners();
  console.log(`ADDRESS: ${account.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
