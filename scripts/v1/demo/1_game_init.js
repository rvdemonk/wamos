const hre = require("hardhat");
const {
  getWamos,
  getWamosBattle,
  ensureBattleIsRegistered,
} = require("./helpers");

async function main() {
  // get players and contracts
  const wamos = await getWamos();
  const battle = await getWamosBattle();
  const [p1, p2] = await hre.ethers.getSigners();
  console.log(
    `Players: p1 ${p1.address.substring(0, 5)} | p2 ${p2.address.substring(
      0,
      5
    )}`
  );
  console.log(`wamos: ${wamos.address}, \n wamos battle: ${battle.address}`);

  await ensureBattleIsRegistered();

  const createTx = await battle.connect(p1).createGame(p2.address);

  const invitesSentbyP1 = await battle
    .connect(p1)
    .getChallengesSentBy(p1.address);

  console.log(invitesSentbyP1);

  // use game id of last invite sent
  const mostRecent = invitesSentbyP1.length - 1;
  console.log(`most recent game id: ${mostRecent}`);
  const gameid = invitesSentbyP1[mostRecent];
  console.log(`--> Last game ID: ${Number(gameid)}, ${gameid}`);

  const gameData = await battle.getGameData(gameid);
  console.log(gameData);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
