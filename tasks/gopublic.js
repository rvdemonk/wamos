task("gopublic", "Toggles to the shared repo wam0s world")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/helpers');
    helpers.setPrivateMode(false);
  })