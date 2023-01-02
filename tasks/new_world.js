task("new_world", "Deploys a new Wamos contract system and updates the front end")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/helpers');
    const active = hre.network.name;
    const deployer = await hre.ethers.getSigner();

    console.log(`\n--- creating a new world on ${active} ---`)
    
    const wamos = await helpers.deployWamos();
    const arena = await helpers.deployArena();
    
    await wamos.setWamosArenaAddress(arena.address);

    helpers.updateFrontend(wamos, arena);

    const subId = hre.config.networks[active].subscriptionId;

    console.log(`getting vrf...`);
    const vrf = await helpers.getVrf();
    console.log(`clearing consumers...`);
    await helpers.clearVrfConsumers(vrf, subId);
    console.log(`adding new contract as consumer...`);
    await vrf.addConsumer(subId, wamos.address);

    console.log("--- the g0ds have awoken ---\n");
  })