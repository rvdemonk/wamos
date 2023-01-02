task("wamo", "Displays the data and traits of the wamo with the given id")
  .addParam("id", "The Wamo's ID number")
  .setAction(async (taskArgs, hre) => {
    const id = taskArgs.id;
    console.log(`Wamo ID: ${taskArgs.id}`);
    
    const helpers = require('../scripts/helpers');
    const wamos = await helpers.getWamos();
    const tokenCount = (await wamos.nextWamoId()) - 1;
    if (id > tokenCount) {
        throw new Error(`Wamo #${id} has not been minted yet! Token count is ${tokenCount}`)
    }
    const traits = await wamos.getTraits(id);
    helpers.displayWamoTraits(id, traits);
})