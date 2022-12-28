const hre = require("hardhat");

async function main() {
  const wamosAddress = hre.config.WAMOS_DEPLOY_ADDR;
  const wamos = await hre.ethers.getContractAt("WamosV1", wamosAddress);
  console.log(`Wamos contract retrieved? ${wamos.address === wamosAddress}`);
  const WamosBattleV1 = await hre.ethers.getContractFactory("WamosBattleV1");
  const network = hre.network.name;
  const chainConfig = hre.config.networks[network];
  const battle = await WamosBattleV1.deploy(
    wamosAddress,
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    );

  console.log(`\nDeployed WamosBattleV1 at ${battle.address}`);


  console.log(`\nSetting battle contract address in wamos...`)
  await wamos.setWamosBattleAddress(battle.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});