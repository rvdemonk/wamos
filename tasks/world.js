task(
  "world",
  "Logs information about the current wamos contract system"
).setAction(async (taskArgs, hre) => {
  // const helpers = require("../scripts/helpers");
  const utils = require("../scripts/utils/");

  const wamos = await utils.getters.getWamos();
  const arena = await utils.getters.getArena();

  const wamosOwner = await wamos.contractOwner();
  const arenaOwner = await arena.contractOwner();

  const wamoCount = (await wamos.nextWamoId()) - 1;
  const wamosTime = await wamos.timestamp();
  const arenaTime = await arena.timestamp();
  // get timestamps
  console.log(`\n--- Active Wamos World ----`);
  console.log("WamosV2:", wamos.address.substring(0, 10));
  console.log("ArenaV2:", arena.address.substring(0, 10));
  console.log(
    `Owner of contracts: [${wamosOwner.substring(0, 6)}, ${arenaOwner.substring(
      0,
      6
    )}]`
  );
  console.log("wamo population:", wamoCount);
  console.log(`wamos deployed @ ${new Date(wamosTime * 1000)}`);
  console.log(`arena deployed @ ${new Date(arenaTime * 1000)}\n`);
});
