const hre = require("hardhat");
const { deployArena, registerLatestArena } = require("./helpers");

async function main() {
  await deployArena();
  await registerLatestArena();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
