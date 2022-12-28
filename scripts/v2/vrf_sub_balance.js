const hre = require("hardhat");
const { getVrf } = require("./helpers");

async function main() {
  const vrf = await getVrf();
//   const balance = vrf.
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
