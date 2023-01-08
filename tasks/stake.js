task("stake", "Stakess Wamos").setAction(async (taskArgs, hre) => {
  const helpers = require("../scripts/helpers");
  console.log(`-- Staking`);
  await helpers.stake();
});
