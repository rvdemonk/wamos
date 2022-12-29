task("world", "Logs information about the current wamos contract system")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/v2/helpers');
    const [ wamos, arena ] = await helpers.getContracts();
    const wamoCount = (await wamos.nextTokenId()) - 1;
    

    console.log(`\n--- Active Wamos World ----`)
    console.log('WamosV2:', wamos.address.substring(0,6));
    console.log('ArenaV2:', arena.address.substring(0,6))
    console.log('\n');
  })