task("new_world", "Deploys a new Wamos contract system and updates the front end")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/v2/helpers');
    const active = hre.network.name;
    const deployer = await hre.ethers.getSigner();
    console.log(`-- creating a new world\n network: ${active}\ndeployer: ${deployer.address}\n`)
    const wamos = await helpers.deployWamos();
    const arena = await helpers.deployArena();
    await wamos.setWamosArenaAddress(arena.address);

    helpers.updateFrontend(wamos, arena);

    const subId = hre.config.networks[active].subscriptionId;
    const vrf = await helpers.getVrf();
    await vrf.addConsumer(subId, wamos.address);
    console.log(" -- new wam0s world deployed --\n");
  })