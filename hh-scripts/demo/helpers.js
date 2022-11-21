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

const mintWamoAs = async (signer) => {
  const wamos = await getWamos();
  const mintPrice = hre.config.WAMOSV1_PRICE;
  const requesttx = await wamos
    .connect(signer)
    .requestSpawnWamo({ value: mintPrice });
  console.log(`Requested wamo spawn with tx ${requesttx.hash}`);
  const requestReceipt = await requesttx.wait();
  const requestEvent = requestReceipt.events.find(
    (event) => event.event === "SpawnRequested"
  );
  const [requestId, tokenId, buyer] = requestEvent.args;
  console.log(
    `\n-> Wamo #${tokenId} spawned by ${signer.address.substring(0, 5)}`
  );
  let vrfFulfilled = await wamos.getSpawnRequestStatus(requestId);

  // wait for request to be fulfilled
  // check every 5 seconds if randomness has been fulfilled for a max 20 blocks
  const startBlock = (await hre.ethers.provider.getBlock("latest")).number;
  const blocksToWait = 20;
  const sleepTime = 3000; // 3 seconds
  let currentBlock;

  while (!vrfFulfilled) {
    currentBlock = (await hre.ethers.provider.getBlock("latest")).number;
    if (currentBlock - startBlock > blocksToWait) {
      console.log(
        `-> exiting process: request unfulfilled after ${blocksToWait}`
      );
      break;
    }
    console.log(`[block ${currentBlock}] randomness not fulfillled...`);
    await sleep(sleepTime);
    vrfFulfilled = await wamos.getSpawnRequestStatus(requestId);
  }

  // if fulfilled show random word and complete mint
  if (vrfFulfilled) {
    console.log(`\nRequest for wamo #${tokenId} fulfilled!\n`);
    console.log(`\n ** COMPLETING MINT\n`);
    const completeSpawntx = await wamos.completeSpawnWamo(tokenId);
    // display traits
    console.log(`Loading traits...`);
    displayTraits(tokenId);
  }
};

const displayTraits = async (wamoId) => {
  const wamos = await getWamos();
  let traits = await wamos.getWamoTraits(wamoId);
  let blockNum = (await hre.ethers.provider.getBlock("latest")).number;
  // check that traits are loaded
  if (traits.health._hex !== "0x00") {
    console.log(`\n---- Wamo #${wamoId} Traits ----\n`);
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }
  } else {
    console.log(`[block ${blockNum}] waiting for traits to load...`);
    setTimeout(() => displayTraits(wamoId), 5000);
  }
};
const sleep = (ms) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};

module.exports = {
  getWamos,
  getWamosBattle,
  ensureBattleIsRegistered,
  getLastChallengeBy,
  mintWamoAs,
  displayTraits,
};
