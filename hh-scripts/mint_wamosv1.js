const hre = require("hardhat");

const WAMOS_ADDR = "0xEBbdA88ddb9f6CCAB03a2841Ff2Ea1F4b14A0E00";

async function displayTraits(wamosContract, wamoId) {
  let traits = await wamosContract.getWamoTraits(wamoId);
  let blockNum = (await hre.ethers.provider.getBlock("latest")).number;
  if (traits.health._hex !== "0x00") {
    console.log(`\n---- Wamo #${wamoId} Traits ----\n`);
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }
  } else {
    console.log(`[block ${blockNum}] request unfulfilled...`);
    setTimeout(() => displayTraits(wamosContract, wamoId), 5000);
  }
}

async function completeMint(wamos, requestId, tokenId) {
  const currentBlock = (await hre.ethers.provider.getBlock("latest")).number;
  const isRequestFulfilled = await wamos.getSpawnRequestStatus(requestId);
  if (!isRequestFulfilled) {
    console.log(`[block ${currentBlock}] waiting for vrf fulfillemt...`);
    setTimeout(() => completeMint(wamos, requestId), 4000);
  } else {
    console.log(`\n Request Fulfilled!`);
    const completetx = await wamos.completeSpawnWamo(tokenId);
    const traits = await wamos.getWamoTraits(tokenId);
    console.log(`\n---- Wamo #${tokenId} Traits ----\n`);
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }
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
  const requesttx = await wamos.requestSpawnWamo({ value: mintPrice });
  console.log(`Requested wamo spawn with tx ${requesttx.hash}`);

  const request = requesttx.wait();
  const event = request.events.find(
    (event) => event.event === "SpawnRequested"
  );
  const [requestId, tokenId, buyer] = event.args;

  console.log(`\nRequest Id: ${requestId}`);
  console.log(`-> Spawning Wamo #${tokenId}`);

  console.log(`\nGetting request data...`);
  let requestData = await wamos.getSpawnRequest(requestId);
  console.log(requestData);

  completeMint(wamos, requestId, tokenId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
