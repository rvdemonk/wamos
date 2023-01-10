const hre = require("hardhat");
const fs = require("fs");
const path = require("path");
const cnts = require("./constants");

function togglePrivateMode(isPrivateMode) {
  const settings = getWorldSettings();
  settings.privateMode = isPrivateMode;
  fs.writeFileSync(cnts.WORLD_SETTINGS, JSON.stringify(settings));
}

function getWorldSettings() {
  const raw = fs.readFileSync(cnts.WORLD_SETTINGS);
  return JSON.parse(raw);
}

function isPrivateModeActive() {
  const settings = getWorldSettings();
  return settings.privateMode;
}

function getActiveWorld() {
  const settings = getWorldSettings();
  const world = settings.privateMode ? "private" : "shared";
  return world;
}

// gets path depending on world settings: priv/shared
function getArtifactDir() {
  const parentDir = cnts.ARTIFACTS_DIR;
  const isPrivateMode = Boolean(getWorldSettings().privateMode);
  const dir = isPrivateMode ? `${parentDir}private` : `${parentDir}shared`;
  return dir;
}

function exportArtifact(contractName, contract) {
  checkArtifactDirectory();
  const exportPath = path.join(getArtifactDir(), `${contractName}.json`);
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
  const artifactsDir = cnts.ARTIFACTS_DIR;
  const privateDir = `${artifactsDir}private/`;
  const sharedDir = `${artifactsDir}shared/`;

  if (!fs.existsSync(artifactsDir)) {
    fs.mkdirSync(artifactsDir);
  }
  if (!fs.existsSync(privateDir)) {
    fs.mkdirSync(privateDir);
  }
  if (!fs.existsSync(sharedDir)) {
    fs.mkdirSync(sharedDir);
  }
}

module.exports = {
  getWorldSettings,
  getActiveWorld,
  getArtifactDir,
  exportArtifact,
  getWamosArtifact,
  getArenaArtifact,
  togglePrivateMode,
};
