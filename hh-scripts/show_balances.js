const hre = require("hardhat");

async function main() {
  const account = await hre.ethers.getSigner();
//   const 
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
