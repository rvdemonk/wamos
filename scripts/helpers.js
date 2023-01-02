const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const ARTIFACTS_DIR = "vite/src/artifacts";

async function deployWamos() {
  const network = hre.network.name;
  const WamosV2 = await hre.ethers.getContractFactory("WamosV2");

  const chainConfig = hre.config.networks[network];
  const mintPrice = hre.config.wamosMintPrice;

  const wamos = await WamosV2.deploy(
    chainConfig.vrfCoordinator,
    chainConfig.gasLane,
    chainConfig.subscriptionId,
    mintPrice
  );
  console.log(`WamosV2 deployed to ${network}\n${wamos.address}\n`)
  return wamos;
}

async function deployArena(wamosAddr = null) {
  const network = hre.network.name;
  const WamosV2Arena = await hre.ethers.getContractFactory("WamosV2Arena");
  
  if (wamosAddr === null) wamosAddr = getWamosArtifact().address;

  const arena = await WamosV2Arena.deploy(
    wamosAddr
  )

  console.log(`WamosV2Arena deployed to ${network}\n${arena.address}`)
  return arena;
}

function exportWamosArtifact(wamos) {
  const artifact = {
    address: wamos.address,
    abi: hre.artifacts.readArtifactSync("WamosV2").abi
  };
  if (!fs.existsSync(ARTIFACTS_DIR)){
    fs.mkdirSync(ARTIFACTS_DIR);
  }
  fs.writeFileSync(path.join(ARTIFACTS_DIR, "WamosV2.json"), JSON.stringify(artifact))
}

function exportArenaArtifact(arena) {
  const artifact = {
    address: arena.address,
    abi: hre.artifacts.readArtifactSync("WamosV2Arena").abi
  };
  fs.writeFileSync(path.join(ARTIFACTS_DIR, "WamosV2Arena.json"), JSON.stringify(artifact))
}

function getWamosArtifact() {
  const rawData = fs.readFileSync(path.join(ARTIFACTS_DIR, "WamosV2.json"));
  return JSON.parse(rawData);
}

function getArenaArtifact() {
  const rawData = fs.readFileSync(path.join(ARTIFACTS_DIR, "WamosV2Arena.json"));
  return JSON.parse(rawData);
}

async function getWamos() {
  const addr = getWamosArtifact().address;
  const wamos = await hre.ethers.getContractAt("WamosV2", addr);
  return wamos;
}

async function getArena() {
  const addr = getArenaArtifact().address;
  const arena = await hre.ethers.getContractAt("WamosV2Arena", addr);
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
  const vrf = await hre.ethers.getContractAt(
    "lib/chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol:VRFCoordinatorV2Interface",
    vrfAddress
  );
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

function displayWamoTraits(id, traits) {
  console.log(`\n---- Wamo #${id} Traits ----\n`);
  for (const property in traits) {
    if (isNaN(Number(property))) {
      console.log(`${traits[property].toString()} | ${property}`);
    }
  }
}

module.exports = {
  deployWamos,
  deployArena,
  exportWamosArtifact,
  exportArenaArtifact,
  getWamosArtifact,
  getArenaArtifact,
  getWamos,
  getArena,
  registerLatestArena,
  getVrf,
  getLinkToken,
  clearVrfConsumers,
  displayWamoTraits
};
