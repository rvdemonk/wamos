const hre = require("hardhat");
const { deployWamos } = require("./helpers");

async function main() {
  const wamos = await deployWamos();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
