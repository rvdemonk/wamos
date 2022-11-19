const hre = require("hardhat");
const { getWamos, getWamosBattle, getLastChallengeBy } = require("./helpers");

async function main() {
  // get players and contracts
  const [p1, p2] = await hre.ethers.getSigners();
  const wamos = await getWamos();
  const battle = await getWamosBattle();
  console.log(`wamos: ${wamos.address}, \n wamos battle: ${battle.address}`);

  const gameid = getLastChallengeBy(p1.address);

  const gameData = await battle.getGameData(gameid);
  console.log(gameData);

  const p1Wamos = [2, 3];
  const p2Wamos = [4, 5];

  // who owns what wamos?
  // for wamos of p1
  // connect
  // for wamos of p2
  //connect

  // players ready up
  //   await battle.connect(p1).
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
