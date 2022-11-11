const hre = require("hardhat");

const MINT_PRICE = hre.ethers.utils.parseUnits("0.001", "ether");
const WAMOS_ADDR = "0x9fbc46624825943482e25Ec18DcD17a94dA7Ad12";

async function main() {
  const deployer = await hre.ethers.getSigner();
  const wamos = await hre.ethers.getContractAt("WamosV1", WAMOS_ADDR);
  console.log("Working with WamosV1 at", (await wamos).address);

  const tokenCount = await wamos.getRequestCount();
  console.log(`Starting token count: ${tokenCount}`);

  const reqId = await wamos.requestSpawnWamo({ value: 2 * MINT_PRICE });
  // console.log(`request id: ${reqId}`);

  console.log(`\nspawn request tx hash: ${reqId.hash}`);
  console.log(Object.keys(reqId));
  console.log(reqId.value);
  console.log(reqId.data);

  // const tokenId = await wamos.getTokenIdFromRequestId(reqId);
  // await wamos.completeSpawnWamo(tokenId);

  console.log(`Finishing token count: ${await wamos.getRequestCount()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
