const hre = require("hardhat");
const { deployWamos } = require("./helpers");

async function main() {
  await deployWamos();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
