task("current_world", "Logs information about the current wamos contract system")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/v2/helpers');
    const [ wamos, arena ] = await helpers.getContracts();

    console.log('WamosV2:', wamos.address.substring(0,6));
  })