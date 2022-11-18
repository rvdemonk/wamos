const hre = require("hardhat");


function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function displayTraits(wamosContract, wamoId) {
  let traits = await wamosContract.getWamoTraits(wamoId);
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
    setTimeout(() => displayTraits(wamosContract, wamoId), 5000);
  }
}

async function main() {
  const wamosAddress = hre.config.WAMOS_DEPLOY_ADDR;
  const wamos = await hre.ethers.getContractAt("WamosV1", wamosAddress);
  const tokenCountStart = await wamos.tokenCount();
  const mintPrice = hre.config.WAMOSV1_PRICE;
  console.log("Working with WamosV1 at", wamos.address);
  console.log(`token count: ${tokenCountStart}`);

  const minter = await hre.ethers.getSigner()

  // PHASE 1: REQUEST MINT
  console.log(`\n ** BEGINNING MINT\n`);
  console.log(`Minting as ${minter.address}`);
  // make request
  const reqStartCount = await wamos.getRequestCount()
  const requesttx = await wamos.requestSpawnWamo({ value: mintPrice });
  console.log(`Requested wamo spawn with tx ${requesttx.hash}`);

  console.log(`\nGetting request receipt`)
  const requestReceipt = await requesttx.wait();
  const requestEvent = requestReceipt.events.find((event) => event.event === "SpawnRequested");
  const [requestId, tokenId, buyer] = requestEvent.args;

  console.log(`\n-> Spawning Wamo #${tokenId}`);
  console.log(`\nRequest Id: ${requestId}`);

  console.log(`\nGetting request data...`);
  let requestData = await wamos.getSpawnRequest(requestId);
  console.log(requestData);

  // check every 5 seconds if randomness has been fulfilled for a max 20 blocks
  const startBlock = (await hre.ethers.provider.getBlock("latest")).number;
  const blocksToWait = 20;
  const sleepTime = 3000; // 3 seconds
  let currentBlock;
  
  let vrfFulfilled = await wamos.getSpawnRequestStatus(requestId);

  // wait for request to be fulfilled
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
    let requestData = await wamos.getSpawnRequest(requestId);
    const word = requestData.randomWord;
    console.log(`\nRequest for wamo #${tokenId} fulfilled!\n`);
    console.log(`random word: ${word}`);

    // PHASE 2: COMPLETE MINT
    console.log(`\n ** COMPLETING MINT\n`);
    const completeSpawntx = await wamos.completeSpawnWamo(tokenId);
    // display traits
    console.log(`Loading traits...`);
    displayTraits(wamos, tokenId);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
