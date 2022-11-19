const hre = require("hardhat");
const { getWamos, getWamosBattle } = require("./helpers");

async function main() {
  // get players and contracts
  const [p1, p2] = await hre.ethers.getSigners();
  const wamos = await getWamos();
  const battle = await getWamosBattle();
  console.log(`wamos: ${wamos.address}, \n wamos battle: ${battle.address}`);

  let rba = await wamos.wamosBattleAddr();
  console.log("rba:", rba);
  if (rba !== battle.address) {
    await wamos.setWamosBattleAddress(await battle.address);
    rba = await wamos.wamosBattleAddr();
    console.log("Registered battle address in wamos: ", rba);
  }

  // await battle.connect(p1).createGame(p2);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
