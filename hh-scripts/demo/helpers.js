const hre = require("hardhat");

const getContracts = async () => {
  const wamosAddress = hre.config.WAMOS_DEPLOY_ADDR;
  const battleAddress = hre.config.WAMOS_BATTLE_ADDR;

  const wamos = hre.ethers.getContractAt("WamosV1", wamosAddress);
  const battle = hre.ethers.getContractAt("WamosBattleV1", battleAddress);

  return [wamos, battle];
};

const getWamos = async () =>
  hre.ethers.getContractAt("WamosV1", hre.config.WAMOS_DEPLOY_ADDR);

const getWamosBattle = async () =>
  hre.ethers.getContractAt("WamosBattleV1", hre.config.WAMOS_BATTLE_ADDR);

const ensureBattleIsRegistered = async () => {
  const wamos = await getWamos();
  const battle = await getWamosBattle();
  const [p1, p2] = await hre.ethers.getSigners();

  let regAddress = await wamos.wamosBattleAddr();
  console.log(`\nCurrent registered battle address: ${regAddress}`);
  if (regAddress !== battle.address) {
    // use signer of the address that owns wamos contracts
    const wamosOwner = await wamos.contractOwner();
    let wamosOwnerSigner;
    if (wamosOwner === p1.address) {
      wamosOwnerSigner = p1;
    } else {
      wamosOwnerSigner = p2;
    }

    // set battle address
    console.log("* Setting battle address...");
    await wamos.connect(wamosOwnerSigner).setWamosBattleAddress(battle.address);
    regAddress = await wamos.wamosBattleAddr();
    console.log(`New registered battle address: ${regAddress}`);
  } else {
    console.log("Battle contract is registered!");
  }
};

const getLastChallengeBy = async (player) => {
  const battle = await getWamosBattle();
  const invitesSentByPlayer = await battle.getChallengesSentBy(player);
  console.log(invitesSentByPlayer);

  // use game id of last invite sent
  const mostRecent = invitesSentByPlayer.length - 1;
  const gameid = invitesSentByPlayer[mostRecent];
  console.log(`--> Last game ID: ${gameid}`);
  return gameid;
};

const displayWamoTraits = async (wamoId) => {};

module.exports = {
  getWamos,
  getWamosBattle,
  ensureBattleIsRegistered,
  getLastChallengeBy,
};
