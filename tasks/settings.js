task("settings", "Get the world settings of the current dev environment")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/helpers');
    const settings = helpers.getWorldSettings();
    console.log(settings);  
})