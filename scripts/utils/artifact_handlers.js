const hre = require("hardhat");
const fs = require("fs");
const path = require("path");
const cnts = require("./constants");

function getWorldSettings() {
  const raw = fs.readFileSync(cnts.WORLD_SETTINGS);
  return JSON.parse(raw);
}

// gets path depending on world settings: priv/shared
function getArtifactDir() {
  const isPrivateMode = Boolean(getWorldSettings().privateMode);
  const dir = isPrivateMode ? cnts.PRIVATE_WORLD_DIR : cnts.SHARED_WORLD_DIR;
  return dir;
}

function exportArtifact(contractName, contract) {
  checkArtifactDirectory();
  const exportPath = path.join(getArtifactDir(), `/${contractName}.json`);
  console.log(`\n    exporting ${contractName} arti to ${exportPath}`);
  const abi = hre.artifacts.readArtifactSync(contractName).abi;
  const artifact = {
    address: contract.address,
    abi: abi,
  };
  fs.writeFileSync(exportPath, JSON.stringify(artifact));
}

function getWamosArtifact() {
  const dir = getArtifactDir();
  const filepath = path.join(dir, "WamosV2.json");
  const rawData = fs.readFileSync(filepath);
  return JSON.parse(rawData);
}

function getArenaArtifact() {
  const dir = getArtifactDir();
  const filepath = path.join(dir, "WamosV2Arena.json");
  const rawData = fs.readFileSync(filepath);
  return JSON.parse(rawData);
}

function checkArtifactDirectory() {
  const isPrivateMode = Boolean(getWorldSettings().privateMode);

  if (isPrivateMode) {
    if (!fs.existsSync(cnts.PRIVATE_WORLD_DIR)) {
      if (!fs.existsSync("world/")) {
        fs.mkdirSync("world/");
      }
      fs.mkdirSync(cnts.PRIVATE_WORLD_DIR);
    }
  } else {
    if (!fs.existsSync(cnts.SHARED_WORLD_DIR)) {
      if (!fs.existsSync("world/")) {
        fs.mkdirSync("world/");
      }
      fs.mkdirSync(cnts.SHARED_WORLD_DIR);
    }
  }
}

module.exports = {
  getWorldSettings,
  getArtifactDir,
  exportArtifact,
  getWamosArtifact,
  getArenaArtifact,
};
