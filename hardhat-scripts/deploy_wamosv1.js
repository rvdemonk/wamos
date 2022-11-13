const hre = require("hardhat");

const MINT_PRICE = hre.ethers.utils.parseUnits("0.001", "ether");

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

  console.log(`${network} vrf coord: ${chainConfig.vrfCoordinator}`);

  const wamos = await WamosV1.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    MINT_PRICE
  );

  console.log(
    `\nDeployed WamosV1 at ${wamos.address} with mint price of ${
      MINT_PRICE / 10 ** 18
    } eth (${MINT_PRICE} wei)`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
