const hre = require("hardhat");

const WAMOS_ADDR = "0xEBbdA88ddb9f6CCAB03a2841Ff2Ea1F4b14A0E00";

async function displayTraits(wamosContract, wamoId) {
  let traits = await wamosContract.getWamoTraits(wamoId);
  if (traits.health._hex !== "0x00") {
    console.log(`\n---- Wamo #${wamoId} Traits ----\n`);
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }
  } else {
    setTimeout(() => displayTraits(wamosContract, wamoId), 3000);
  }
}

async function main() {
  const wamos = await hre.ethers.getContractAt("WamosV1", WAMOS_ADDR);
  const tokenCountStart = await wamos.tokenCount();
  const mintPrice = hre.config.WAMOSV1_PRICE;
  console.log("Working with WamosV1 at", wamos.address);
  console.log(`token count: ${tokenCountStart}`);
  console.log(`mint price: ${mintPrice / 10 ** 18}`);
  console.log(`callback gas limit: ${await wamos.vrfCallbackGasLimit()}`);

  // PHASE 1: REQUEST MINT
  console.log(`\n ** BEGINNING MINT\n`);

  console.log("request count before req:", await wamos.getRequestCount())
  const requesttx = await wamos.requestSpawnWamo({ value: mintPrice });
  console.log(`Requested wamo spawn with tx ${requesttx.hash}`);

  const requestCount = await wamos.getRequestCount();
  console.log("request count after req", requestCount);
  const requestId = await wamos.requestIds(requestCount - 1);
  console.log(`\nRequest Id: ${requestId}`);

  const tokenId = await wamos.getTokenIdFromRequestId(requestId);
  console.log(`-> Spawning Wamo #${tokenId}`);

  console.log(`\nGetting request status...`);
  let requestData = await wamos.getSpawnRequest(requestId);
  console.log(requestData);

  // check every 5 seconds if randomness has been fulfilled for a max 20 blocks
  const startBlock = hre.network.block;
  const blocksToWait = 20;
  let currentBlock;

  let isRequestFulfilled = await wamos.getSpawnRequestStatus(requestId);
  while (!isRequestFulfilled) {
    currentBlock = await hre.network.block;
    setTimeout(async () => {
      console.log(`[block ${currentBlock}] randomness not fulfillled...`);
      isRequestFulfilled = await wamos.getSpawnRequestStatus(requestId);
    }, 5000);

    if (currentBlock - startBlock > blocksToWait) {
      console.log(
        `-> exiting process: request unfulfilled after ${blocksToWait}`
      );
      break;
    }
  }

  // if fulfilled show random word and complete mint
  if (isRequestFulfilled) {
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
