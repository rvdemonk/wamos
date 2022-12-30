task("new_world", "Deploys a new Wamos contract system and updates the front end")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/v2/helpers');
    const active = hre.network.name;
    const deployer = await hre.ethers.getSigner();
    console.log(`-- creating a new world on ${active} --`)
    // deploy contracts
    const wamos = await helpers.deployWamos();
    const arena = await helpers.deployArena();
    // set arena address
    await wamos.setWamosArenaAddress(arena.address);
    // update frontend with new artifacts
    helpers.updateFrontend(wamos, arena);
    const subId = hre.config.networks[active].subscriptionId;
    const vrf = await helpers.getVrf();
    // clear consumers and add new wamos
    await helpers.clearVrfConsumers(vrf, active);
    await vrf.addConsumer(subId, wamos.address);
    console.log("\n -- the g0ds have awoken --\n");
  })