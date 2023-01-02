const hre = require("hardhat");
const path = require("path");

async function main() {
  await deployWamos();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
