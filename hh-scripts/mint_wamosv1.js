const hre = require("hardhat");

const WAMOS_ADDR = "0x5db430a5155A798454AA42875e1C1a272CA20923";

async function main() {
  const wamos = await hre.ethers.getContractAt("WamosV1", WAMOS_ADDR);
  const tokenCountStart = await wamos.tokenCount();
  const mintPrice = hre.config.WAMOSV1_PRICE;
  console.log("Working with WamosV1 at", wamos.address);
  console.log(`token count: ${tokenCountStart}`);
  console.log(`mint price: ${mintPrice}`);

  // mint

  let req = await wamos.requestSpawnWamo({value: mintPrice});
  console.log(`Requested wamo spawn with tx ${req.hash}`);

  const tokenCountEnd = await wamos.tokenCount();

  console.log(`Token mint successful -> ${tokenCountEnd !== tokenCountStart}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
