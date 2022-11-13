const hre = require("hardhat");

async function main() {
  const WamosV1 = await hre.ethers.getContractFactory("WamosV1");

  const network = hre.network.name;
  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.WAMOSV1_PRICE;
  // const mintPrice = hre.ethers.utils.parseEther(hre.config.MINT_PRICE)

  console.log(`${network} vrf coord: ${chainConfig.vrfCoordinator}`);

  // deploy
  const wamos = await WamosV1.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );

  console.log(`\nDeployed WamosV1 at ${wamos.address}`);

  // adding as consumer
  await wamos.vrfCoordinator.addConsumer(chainConfig.subscriptionId, wamos.address);

  // mint
  const tokenCountStart = await wamos.tokenCount();
  // no payment value for this test deployment contract version
  let req = await wamos.requestWamoSpawn({value: mintPrice});
  console.log(`Requested wamo spawn with tx ${req.hash}`);
  const tokenCountEnd = await wamos.tokenCount();
  console.log(`Token mint successful -> ${tokenCountEnd !== tokenCountStart}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
