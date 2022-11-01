const hre = require("hardhat");

async function main() {
  const Randomness= await hre.ethers.getContractFactory(
    "WamosRandomnessV0"
  );
  const randomness = await VRFConsumerV0.deploy();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
