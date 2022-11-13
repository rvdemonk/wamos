const hre = require("hardhat");

const MINT_PRICE = hre.ethers.utils.parseUnits("0.001", "ether");
const WAMOS_ADDR = "0xF6BBcb05cE963dAD7851c43D92A0958dFd1eCA75";

async function main() {
  const deployer = await hre.ethers.getSigner();
  const wamos = await hre.ethers.getContractAt("WamosV1", WAMOS_ADDR);
  console.log("Working with WamosV1 at", (await wamos).address);

  let tokenCount = await wamos.getRequestCount();
  console.log(`Starting token count: ${tokenCount}`);

  const reqId = await wamos.requestSpawnWamo();
  // console.log(`request id: ${reqId}`);

  console.log(`\nspawn request tx hash: ${reqId.hash}`);

  // const tokenId = await wamos.getTokenIdFromRequestId(reqId);
  // await wamos.completeSpawnWamo(tokenId);

  console.log(`Finishing token count: ${await wamos.getRequestCount()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
