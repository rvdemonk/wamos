const hre = require("hardhat");
const { deployWamos, deployArena, registerLatestArena, getVrf, getAddresses } = require("./helpers");

async function main() {
  const deprecatedContracts = getAddresses();
  const active = hre.network.name;
  const deployer = await hre.ethers.getSigner();
  console.log(`-- creating a new world\n network: ${active}\ndeployer: ${deployer.address}\n`)
  const wamos = await deployWamos();
  const arena = await deployArena();
  await registerLatestArena();
  // set up wamos vrf subscription
  const subId = hre.config.networks[active].subscriptionId;
  console.log(`Adding new WamosV2 as vrf consoomer to sub ${subId}...`);
  const vrf = await getVrf();
  console.log(`workin' with the ${active} vrf coordinator`)
  // await vrf.removeConsumer(subId, deprecatedContracts.WamosV2);
  await vrf.addConsumer(subId, wamos.address);
  console.log(
    `\n -- New Wam0s World --\n`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
