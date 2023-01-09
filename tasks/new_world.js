task(
  "new_world",
  "Deploys a new Wamos contract system and updates the front end"
).setAction(async (taskArgs, hre) => {
  const helpers = require("../scripts/helpers");
  const active = hre.network.name;
  const deployer = await hre.ethers.getSigner();
  const balStart = await helpers.getDeployerBalance();
  console.log(`\n--- creating a new world on ${active} ---`);
  const wamos = await helpers.deployWamos();
  const arena = await helpers.deployArena(wamos.address);
  console.log("** setting arena address");
  await wamos.setWamosArenaAddress(arena.address);

  console.log("** exporting artifacts");
  // helpers.exportWamosArtifact(wamos);
  // helpers.exportArenaArtifact(arena);
  helpers.exportArtifact("WamosV2", wamos);
  helpers.exportArtifact("WamosV2Arena", arena);

  const subId = hre.config.networks[active].subscriptionId;

  console.log(`** getting vrf`);
  const vrf = await helpers.getVrf();
  const subData = await vrf.getSubscription(subId);
  console.log("** checking number of consumers");
  if (subData.consumers.length > 3) {
    console.log(`  *consumer limit reached - clearing`);
    await helpers.clearVrfConsumers(vrf, subId);
  }

  console.log(`** adding new contract as consumer`);
  await vrf.addConsumer(subId, wamos.address);

  console.log("\n--- the g0ds have awoken ---");
  const balEnd = await helpers.getDeployerBalance();
  console.log(
    `Total cost: ${((balStart - balEnd) / 10 ** 18)
      .toString()
      .substring(0, 6)} MATIC`
  );

  // now mint 5 wamos each for devs
  // const devConfig = JSON.parse(require("fs").readFileSync("./dev-config.json"));
  // console.log(devConfig);
});
