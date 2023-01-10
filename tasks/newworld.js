task(
  "newworld",
  "Deploys a new Wamos contract system and updates the front end"
).setAction(async (taskArgs, hre) => {
  const utils = require("../scripts/utils");
  const active = hre.network.name;
  const deployer = await hre.ethers.getSigner();

  const balStart = await utils.callers.getDeployerBalance();

  console.log(`\n--- creating a new world on ${active} ---`);
  const wamos = await utils.deployers.deployWamos();
  const arena = await utils.deployers.deployArena(wamos.address);

  console.log("\n** setting arena address");
  await wamos.setWamosArenaAddress(arena.address);

  console.log("exporting artifacts");
  utils.artifact_handlers.exportArtifact("WamosV2", wamos);
  utils.artifact_handlers.exportArtifact("WamosV2Arena", arena);

  const subId = hre.config.networks[active].subscriptionId;
  console.log(`vrf subscription #${subId}`);

  console.log(`** getting vrf`);
  const vrf = await utils.getters.getVrf();

  console.log("checking number of consumers");
  const subData = await vrf.getSubscription(subId);
  if (subData.consumers.length > 3) {
    console.log(`  *consumer limit reached - clearing`);
    await helpers.clearVrfConsumers(vrf, subId);
  }

  console.log(`adding new contract as consumer`);
  await vrf.addConsumer(subId, wamos.address);

  console.log("\n--- the g0ds have awoken ---");
  const balEnd = await utils.callers.getDeployerBalance();
  console.log(
    `Total cost: ${((balStart - balEnd) / 10 ** 18)
      .toString()
      .substring(0, 6)} MATIC`
  );

  // now mint 5 wamos each for devs
  // const devConfig = JSON.parse(require("fs").readFileSync("./dev-config.json"));
  // console.log(devConfig);
});
