const hre = require("hardhat");

const WAMOS_ADDR = "0x5db430a5155A798454AA42875e1C1a272CA20923";

async function main() {
  const wamos = await hre.ethers.getContractAt("WamosV1", WAMOS_ADDR);
  const tokenCountStart = await wamos.tokenCount();
  const mintPrice = hre.config.WAMOSV1_PRICE;
  console.log("Working with WamosV1 at", wamos.address);
  console.log(`token count: ${tokenCountStart}`);
  console.log(`mint price: ${mintPrice}`);

  // request mint: phase 1
  let requestId = await wamos.requestSpawnWamo({value: mintPrice});
  console.log(`Requested wamo spawn with tx ${req.hash}`);

  const tokenCountEnd = await wamos.tokenCount();
  console.log(`Request sent? -> ${tokenCountEnd !== tokenCountStart}`);

  // wait until randomness fulfilled
  const startBlock = hre.network.block;
  const blocksToWait = 20;
  let isRequestFulfilled = await wamos.getSpawnRequestStatus(requestId);
  let currentBlock;
  while (!isRequestFulfilled) {
    currentBlock = await hre.network.block
    console.log(`[block ${currentBlock}] randomness not fulfillled...`);
    setTimeout(async () => {
      isRequestFulfilled = await wamos.getSpawnRequestStatus(requestId);
    }, 5000)
    if (currentBlock - startBlock > blocksToWait) {
      console.log(`-> exiting process after ${blocksToWait}`);
      break
    }

    if (isRequestFulfilled) {
      console.log(`Request fulfilled!`);
      const tokenId = await wamos.getTokenIdFromRequestId(requestId);
      const requestStruct = await wamos.getSpawnRequest(tokenId);
      const word = requestStruct.randomWord;
      
    }
  }

  // complete mint: phase 2
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
