const hre = require("hardhat");
const { getWamos, getWamosBattle, mintWamoAs } = require("./helpers");

async function main() {
  // get players and contracts
  const [p1, p2] = await hre.ethers.getSigners();
  const wamos = await getWamos();
  const battle = await getWamosBattle();

  for (const i = 0; i < 2; i++) {
    await mintWamoAs(p1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
