const hre = require("hardhat");
const { deployWamos, deployArena, registerLatestArena } = require("./helpers");

async function main() {
  const wamos = await deployWamos();
  const arena = await deployArena();
  await registerLatestArena();
  // set up wamos vrf subscription
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
