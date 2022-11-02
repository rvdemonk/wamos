const { network } = require("hardhat");
const hre = require("hardhat");

GAS_LIMIT = 1000000;

async function main() {
  const deployer = hre.ethers.getSigners();
  const chain = await hre.network.name;
  const chainId = await network.config.chainId;
  console.log(chain);

  const WamosRandomnessV0 = await hre.ethers.getContractFactory(
    "WamosRandomnessV0"
  );
  let args;
  // if (chainId == hre.config.networks.mumbai.chainId) {}
  args = [
    hre.config.networks.mumbai.subscriptionId,
    hre.config.networks.mumbai.vrfCoordinator,
    hre.config.networks.mumbai.gasLane,
  ];

  const randomness = await WamosRandomnessV0.deploy(
    hre.config.networks.mumbai.subscriptionId,
    hre.config.networks.mumbai.vrfCoordinator,
    hre.config.networks.mumbai.gasLane
  );
  const keyHash = await randomness.keyHash();
  console.log(`keyhash: ${keyHash}`);

  const requestId = await randomness.requestRandomWords(1, GAS_LIMIT);

  const requestCount = await randomness.getRequestCount();
  console.log(`request count: ${requestCount}`);

  const [status, words] = await randomness.getRequestStatus(requestId);
  console.log(`status: ${status}  \nwords:${words}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
