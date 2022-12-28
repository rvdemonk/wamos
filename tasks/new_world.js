task("new_world", "Deploys a new Wamos contract system and updates the front end")
  .setTask(async (taskArgs, hre) => {
    const active = hre.network.name;
    const deployer = await hre.ethers.getSigner();
    console.log(`-- creating a new world\n network: ${active}\ndeployer: ${deployer.address}\n`)
    const wamos = await deployWamos();
    const arena = await deployArena();
    require("../scripts/v2/helpers").updateFrontend(wamos, arena);

    const subId = hre.config.networks[active].subscriptionId;
    const vrf = await getVrf();
    await vrf.addConsumer(subId, wamos.address);
    console.log(" -- new wam0s world deployed --\n");
  })