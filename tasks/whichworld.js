task(
  "whichworld",
  "Logs whether you are on private or shared wamos world"
).setAction(async (taskArgs, hre) => {
  const utils = require("../scripts/utils/");
  const settings = utils.artifact_handlers.getWorldSettings();
  const world = settings.privateMode ? "private" : "shared";
  console.log(world);
});
