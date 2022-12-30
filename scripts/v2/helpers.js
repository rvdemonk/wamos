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
    `Deploying WamosV2 on ${network} from ${deployer.address.substring(0,6)}`
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
    `Deploying WamosV2Arena on ${network} from ${deployer.address.substring(0,6)}`
  );
  const arena = await WamosV2Arena.deploy(
    artifacts.WamosV2Address
  )
  console.log(`WamosV2 ARENA deployed to: ${arena.address}`);
  return arena;
}

async function getWamos() {
  const addr = getArtifacts().WamosV2Address;
  const wamos = await hre.ethers.getContractAt("WamosV2", addr);
  return wamos;
}

async function getArena() {
  const addr = getArtifacts().WamosV2ArenaAddress;
  const arena = await hre.ethers.getContractAt("WamosV2Arena", addr);
  return arena;
}

async function getContracts() {
  const artifacts = getArtifacts();
  const wamos = await hre.ethers.getContractAt("WamosV2", artifacts.WamosV2Address);
  const arena = await hre.ethers.getContractAt("WamosV2Arena", artifacts.WamosV2ArenaAddress);
  return [wamos, arena];
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

async function clearVrfConsumers(vrf, subId) {
  let subData = await vrf.getSubscription(subId);
  const consumers = subData.consumers;
  for (let i=0; i<consumers.length; i++) {
      await vrf.removeConsumer(subId, consumers[i]);
  }
}

async function getLinkToken() {
  const activeChain = hre.network.name;
  const linkAddr = config.networks[activeChain]["linkToken"];
  console.log(`Getting Link Token on ${activeChain}`);
  const LinkToken = await ethers.getContractAt("LinkToken", linkAddr);
  return LinkToken;
}

function updateFrontend(wamos, arena) {
  console.log('saving files to frontend ->', CONTRACTS_DIR);
  const artifacts = {
    "WamosV2Address": wamos.address,
    "WamosV2ABI": hre.artifacts.readArtifactSync("WamosV2"),
    "WamosV2ArenaAddress": arena.address,
    "WamosV2ArenaABI": hre.artifacts.readArtifactSync("WamosV2Arena"),
  }
  fs.writeFileSync(path.join(CONTRACTS_DIR, "artifacts.json"), JSON.stringify(artifacts));
  console.log(` - files saved ->`, CONTRACTS_DIR);
} 

module.exports = {
  deployWamos,
  deployArena,
  getWamos,
  getArena,
  getContracts,
  registerLatestArena,
  getVrf,
  getArtifacts,
  updateFrontend,
  getLinkToken,
  clearVrfConsumers
};
