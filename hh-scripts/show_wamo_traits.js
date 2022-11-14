const hre = require('hardhat');

const NAME = "WamosV1";
const ADDR = "0x94C3d1DAD1c5663862724968269ED927Be9278d2";
const WAMOID = 10;

async function main() {
  const wamos = await hre.ethers.getContractAt(NAME, ADDR);
//   console.log(`\nLoaded ${NAME} at ${wamos.address}`);

  const traits = await wamos.getWamoTraits(10);

  console.log(traits);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
  