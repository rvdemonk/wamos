task("mint", "Mints Wamos")
    .addParam("", "The Wamo's ID number")
    .setAction(async (taskArgs, hre) => {
        const helpers = require('../scripts/helpers');
        const wamos = await helpers.getWamos();
        
    })