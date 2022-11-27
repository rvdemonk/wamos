const hre = require("hardhat");

async function main() {
  if (hre.network.name !== "hardhat") {
    console.log();
  } else {
    console.log("Deploying on hardhat");
    const GaussianRNG = hre.ethers.getContractFactory("GaussianRNG");
    const grng = GaussianRNG.deploy();
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
