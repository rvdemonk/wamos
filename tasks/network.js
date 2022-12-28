task("network", "Logs the active network")
  .setAction(async (taskArgs, hre) => {
    const active = await hre.network.name;
    console.log('network:', active);
  })