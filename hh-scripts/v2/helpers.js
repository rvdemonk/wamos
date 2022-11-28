const hre = require("hardhat");

// returns contract object
async function deployWamos() {
  const deployer = await hre.ethers.getSigner();
  const network = hre.network.name;
  const WamosV2 = await hre.ethers.getContractFactory("WamosV2");

  console.log(
    `Deploying WamosV2 on ${network} from ${(await deployer).address}`
  );

  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.WAMOSV1_PRICE;

  const wamos = await WamosV2.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );

  console.log("WamosV2 deployed at: ", wamos.address);
  return wamos;
}

module.exports = {
  deployWamos,
};
