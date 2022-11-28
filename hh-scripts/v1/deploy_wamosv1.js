const hre = require("hardhat");

async function main() {
  const deployer = await hre.ethers.getSigner();
  console.log(`Deployer address ${deployer.address.substring(0, 6)}`);
  console.log(
    `Deployer balance: ${((await deployer.getBalance()) / 10 ** 18).toFixed(
      3
    )} matic`
  );

  const WamosV1 = await hre.ethers.getContractFactory("WamosV1");

  const network = hre.network.name;
  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.WAMOSV1_PRICE;

  console.log(`${network} vrf coord: ${chainConfig.vrfCoordinator}`);

  const wamos = await WamosV1.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );

  console.log(
    `\nDeployed WamosV1 at ${wamos.address} with mint price of ${
      mintPrice/ 10 ** 18
    } eth (${mintPrice} wei)`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
