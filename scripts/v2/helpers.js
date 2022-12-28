const hre = require("hardhat");
const fs = require('fs');
const path = require("path");

const CONTRACTS_DIR = "vite/src/";

function getArtifacts() {
  const rawData = fs.readFileSync(path.join(CONTRACTS_DIR,'artifacts.json'));
  const artifacts = JSON.parse(rawData);
  return artifacts;
}

// returns contract object
async function deployWamos() {
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
  console.log("WamosV2 deployed to: ", wamos.address);
  return wamos;
}

async function deployArena() {
  const deployer = await hre.ethers.getSigner();
  const network = hre.network.name;
  const WamosV2Arena = await hre.ethers.getContractFactory("WamosV2Arena");
  
  const artifacts = getArtifacts();
  console.log(
    `Deploying WamosV2Arena on ${network} from ${deployer.address}`
  );
  const arena = await WamosV2Arena.deploy(
    artifacts.WamosV2Address
  )
  console.log(`WamosV2 ARENA deployed to: ${arena.address}`);
  return arena;
}

async function getWamos() {
  const addr = getArtifacts().WamosV2Address;
  console.log(addr);
  const wamos = hre.ethers.getContractAt("WamosV2", addr);
  return wamos;
}

async function getArena() {
  const addr = getArtifacts().WamosV2ArenaAddress;
  const arena = hre.ethers.getContractAt("WamosV2Arena", addr);
  return arena;
}

async function registerLatestArena() {
  const wamos = await getWamos();
  const artifacts = getArtifacts();
  await wamos.setWamosArenaAddress(artifacts.WamosV2ArenaAddress);
}

async function getVrf() {
  const chain = hre.network.name;
  const vrfAddress = hre.config.networks[chain].vrfCoordinator;
  const vrf = await hre.ethers.getContractAt("lib/chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol:VRFCoordinatorV2Interface", vrfAddress);
  return vrf;
}

function updateFrontend(wamos, arena) {
  console.log('saving files to frontend...')
  const artifacts = {
    "WamosV2Address": wamos.address,
    "WamosV2ABI": hre.artifacts.readArtifactSync("WamosV2"),
    "WamosV2ArenaAddress": arena.address,
    "WamosV2ArenaABI": hre.artifacts.readArtifactSync("WamosV2Arena"),
  }
  fs.writeFileSync(path.join(CONTRACTS_DIR, "artifacts.json"), JSON.stringify(artifacts));
} 

module.exports = {
  deployWamos,
  deployArena,
  getWamos,
  getArena,
  registerLatestArena,
  getVrf,
  getArtifacts,
  updateFrontend
};
