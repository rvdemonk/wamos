const hre = require("hardhat");
const fs = require("fs");

function exportArtifact(contractName, contract) {
  const abi = hre.artifacts.readArtifactSync(contractName).abi;
  const artifact = {
    address: contract.address,
    abi: abi,
  };

  const isPrivateMode = Boolean(getWorldSettings().privateMode);
  let exportPath;

  if (isPrivateMode) {
    if (!fs.existsSync(PRIVATE_DIR)) {
      if (!fs.existsSync("world/")) {
        fs.mkdirSync("world/");
      }
      fs.mkdirSync(PRIVATE_DIR);
    }
    // set path
    exportPath = PRIVATE_DIR;
  } else {
    if (!fs.existsSync(PUBLIC_DIR)) {
      if (!fs.existsSync("world/")) {
        fs.mkdirSync("world/");
      }
      fs.mkdirSync(PUBLIC_DIR);
    }
  }
  exportPath = PRIVATE_DIR;
  fs.writeFileSync(
    path.join(exportPath, `${contractName}.json`),
    JSON.stringify(artifact)
  );
}

function getWamosArtifact() {
  //   // todo check if world env is private or public
  //   const settings = getWorldSettings();

  const rawData = fs.readFileSync(path.join(ARTIFACTS_DIR, "WamosV2.json"));
  return JSON.parse(rawData);
}

function getArenaArtifact() {
  const rawData = fs.readFileSync(
    path.join(ARTIFACTS_DIR, "WamosV2Arena.json")
  );
  return JSON.parse(rawData);
}
