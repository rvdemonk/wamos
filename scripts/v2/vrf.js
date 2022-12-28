const hre = require("hardhat");
const { getVrf} = require("./helpers");

async function main() {
  const vrf = await getVrf();
  await vrf.removeConsumer(2476, "0x5c4980f343f2726ade2bce1d45c93d46b660d1b5");
  console.log(vrf.address);
  console.log(await vrf.getRequestConfig());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
