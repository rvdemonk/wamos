task("goprivate", "Changes the active world to private/shared").setAction(
  async (taskArgs, hre) => {
    const utils = require("../scripts/utils/");
    utils.artifact_handlers.togglePrivateMode(true);
    const world = utils.artifact_handlers.getActiveWorld();
    console.log(`${world} world active`);
  }
);
