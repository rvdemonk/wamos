task("wamo", "Displays the data and traits of the wamo with the given id")
  .addParam("id", "The Wamo's ID number")
  .setAction(async (taskArgs, hre) => {
    const utils = require("../scripts/utils/");

    const id = taskArgs.id;
    console.log(`Wamo ID: ${taskArgs.id}`);

    const wamos = await utils.getters.getWamos();
    const tokenCount = (await wamos.nextWamoId()) - 1;
    if (id > tokenCount) {
      throw new Error(
        `Wamo #${id} has not been minted yet! Token count is ${tokenCount}`
      );
    }
    const traits = await wamos.getTraits(id);
    helpers.displayWamoTraits(id, traits);
  });
