const hre = require("hardhat");
const path = require("path");

async function main() {
  const deployer = await hre.ethers.getSigner();
  console.log(`Deployer address ${deployer.address.substring(0, 6)}`);
  console.log(
    `Deployer balance: ${((await deployer.getBalance()) / 10 ** 18).toFixed(
      3
    )} matic`
  );

  const WamosV2 = await hre.ethers.getContractFactory("WamosV2");

  const WamosV2Arena = await hre.ethers.getContractFactory("WamosV2Arena");

  const network = hre.network.name;
  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.WAMOSV1_PRICE;

  console.log(`${network} vrf coord: ${chainConfig.vrfCoordinator}`);

  const wamos = await WamosV2.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );

  const arena = await WamosV2Arena.deploy(wamos.address);

  saveFrontendFiles(wamos, arena);
}

function saveFrontendFiles(wamos, arena) {
  const fs = require("fs");
  const contractsDir = path.join(__dirname, "contracts");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "WamosV2-contract-address.json"),
    JSON.stringify({ WamosV2: wamos.address }, undefined, 2)
  );

  fs.writeFileSync(
    path.join(contractsDir, "WamosV2Arena-contract-address.json"),
    JSON.stringify({ WamosV2Arena: arena.address }, undefined, 2)
  );

  const WamosV2Artifact = artifacts.readArtifactSync("WamosV2");
  const WamosV2ArenaArtifact = artifacts.readArtifactSync("WamosV2Arena");

  fs.writeFileSync(
    path.join(contractsDir, "WamosV2Arena.json"),
    JSON.stringify(WamosV2ArenaArtifact, null, 2)
  );
  fs.writeFileSync(
    path.join(contractsDir, "WamosV2.json"),
    JSON.stringify(WamosV2Artifact, null, 2)
  );

  const data = {
    WamoAddress: wamos.address,
    ArenaAddress: arena.address,
  };
  console.table(data);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
