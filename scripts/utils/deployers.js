const hre = require("hardhat");
const fs = require("fs");

async function deployWamos() {
  const network = hre.network.name;
  const WamosV2 = await hre.ethers.getContractFactory("WamosV2");

  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.wamosMintPrice;
  console.log(` -- deploying wamos`);
  const wamos = await WamosV2.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );
  console.log(`WamosV2 deployed to ${network}\n${wamos.address}`);
  return wamos;
}

async function deployArena(wamosAddr = null) {
  const network = hre.network.name;
  const WamosV2Arena = await hre.ethers.getContractFactory("WamosV2Arena");

  // by default connects to most recent deployment of wamos, unless other address
  // specified
  if (wamosAddr === null) wamosAddr = getWamosArtifact().address;
  console.log(` -- deploying arena`);
  const arena = await WamosV2Arena.deploy(wamosAddr);

  console.log(`WamosV2Arena deployed to ${network}\n${arena.address}`);
  return arena;
}

// module.exports = {
//   deployWamos,
//   deployArena,
// };
