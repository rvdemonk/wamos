task("new_world", "Deploys a new Wamos contract system and updates the front end")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/helpers');
    const active = hre.network.name;
    const deployer = await hre.ethers.getSigner();

    console.log(`\n--- creating a new world on ${active} ---`)
    console.log('** deploying contracts')
    const wamos = await helpers.deployWamos();
    const arena = await helpers.deployArena(wamos.address);
    console.log('** setting arena address')
    await wamos.setWamosArenaAddress(arena.address);

    console.log('** exporting artifacts');
    helpers.exportWamosArtifact(wamos);
    helpers.exportArenaArtifact(arena);

    const subId = hre.config.networks[active].subscriptionId;
    
    console.log(`** getting vrf`);
    const vrf = await helpers.getVrf();
    const subData = await vrf.getSubscription(subId);
    console.log('** checking number of consumers')
    if (subData.consumers.length > 3) {
      console.log(`Consumer limit reached - clearing`);
      await helpers.clearVrfConsumers(vrf, subId);
    }

    console.log(`** adding new contract as consumer`);
    await vrf.addConsumer(subId, wamos.address);

    console.log("--- the g0ds have awoken ---\n");
  })