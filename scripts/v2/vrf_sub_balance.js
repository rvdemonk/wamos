const hre = require("hardhat");
const { getVrf } = require("./helpers");

async function main() {
  const active = await hre.network.name;
  const vrf = await getVrf();
  const subId = hre.config.networks[active].subscriptionId;
  const subData = await vrf.getSubscription(subId);
  console.log(subData);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
