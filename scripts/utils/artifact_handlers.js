const hre = require("hardhat");
const fs = require("fs");
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
  const exportPath = getArtifactDir();
  const abi = hre.artifacts.readArtifactSync(contractName).abi;
  const artifact = {
    address: contract.address,
    abi: abi,
  };
  fs.writeFileSync(
    path.join(exportPath, `${contractName}.json`),
    JSON.stringify(artifact)
  );
}

function getWamosArtifact() {
  const dir = getArtifactDir();
  console.log(`!! getting wamos artifact`);
  const filepath = path.join(dir, "WamosV2.json");
  console.log("-->", filepath);
  const rawData = fs.readFileSync(filepath);
  return JSON.parse(rawData);
}

function getArenaArtifact() {
  const dir = getArtifactDir();
  console.log(`!! getting arena artifact`);
  const rawData = fs.readFileSync(path.join(dir, "WamosV2Arena.json"));
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
