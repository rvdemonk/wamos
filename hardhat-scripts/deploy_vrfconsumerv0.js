const hre = require("hardhat");

async function main() {
  const VRFConsumerV0 = await hre.ethers.getContractFactory(
    "WamosVRFConsumerV0"
  );
  const consumerV0 = await VRFConsumerV0.deploy();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
