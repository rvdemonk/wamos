const hre = require("hardhat");
const fs = require('fs');

function getAddresses() {
  const rawData = fs.readFileSync('deployments.json');
  const deployments = JSON.parse(rawData);
  return deployments;
}

function updateAddresses(deployments) {
  const rawData = JSON.stringify(deployments);
  fs.writeFileSync('deployments.json', rawData)
}

// returns contract object
async function deployWamos(saveDeploy = true) {
  const deployer = await hre.ethers.getSigner();
  const network = hre.network.name;
  const WamosV2 = await hre.ethers.getContractFactory("WamosV2");

  console.log(
    `Deploying WamosV2 on ${network} from ${deployer.address}`
  );

  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.WAMOSV1_PRICE;

  const wamos = await WamosV2.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );

  if (saveDeploy) {
    const addr = getAddresses();
    addr.WamosV2 = wamos.address;
    updateAddresses(addr);
  }
  
  console.log("WamosV2 deployed at: ", wamos.address);
  return wamos;
}

async function deployArena(saveDeploy = true) {
  const deployer = await hre.ethers.getSigner();
  const network = hre.network.name;
  const WamosV2Arena = await hre.ethers.getContractFactory("WamosV2Arena");

  // const chainConfig = hre.config.networks[network];
  const deployments = getAddresses();

  console.log(
    `Deploying WamosV2Arena on ${network} from ${deployer.address}`
  );

  const arena = await WamosV2Arena.deploy(
    deployments.WamosV2
  )

  if (saveDeploy) {
    // save arena address
    deployments.WamosV2Arena = arena.address;
    updateAddresses(deployments);
  }

  // arena subscription must be set up and funded

  console.log(`WamosV2 ARENA deployed to: ${arena.address}`);
  return arena;
}

async function getWamos() {
  const addr = getAddresses();
  const wamos = hre.ethers.getContractAt("WamosV2", addr.WamosV2);
  return wamos;
}

async function getArena() {
  const addr = getAddresses();
  const arena = hre.ethers.getContractAt("WamosV2Arena", addr.WamosV2Arena);
  return arena;
}

async function registerLatestArena() {
  const wamos = await getWamos();
  const deployments = getAddresses();
  const arenaAddr = deployments.WamosV2Arena;
  if (arenaAddr === "") {
    throw 'No WamosV2Arena has been deployed!'
  }
  await wamos.setWamosArenaAddress(arenaAddr);
}

module.exports = {
  deployWamos,
  deployArena,
  getWamos,
  getArena,
  registerLatestArena
};
