const hre = require("hardhat");
const { deployArena } = require("./helpers");

async function main() {
  await deployArena();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
