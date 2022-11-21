const hre = require("hardhat");
const { getWamos, getWamosBattle, getLastChallengeBy } = require("./helpers");

async function main() {
  // get players and contracts
  const [p1, p2] = await hre.ethers.getSigners();
  const wamos = await getWamos();
  const battle = await getWamosBattle();
  console.log(`wamos: ${wamos.address}, \n wamos battle: ${battle.address}`);

  const gameid = getLastChallengeBy(p1.address);

  // ready up p1
  // ready up 2

  const data = await wamos.getGameData(gameid);

  console.log(`Game ONFOOT? ${data.status === 1}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
