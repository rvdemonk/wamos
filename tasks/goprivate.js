task("goprivate", "Toggles to your personal wam0s world")
  .setAction(async (taskArgs, hre) => {
    const helpers = require('../scripts/helpers');
    helpers.setPrivateMode(true);
  })