const hre = require("hardhat");
const fs = require("fs");
const ct = require("./constants");
const ah = require("./artifact_handlers");

async function getWamos() {
  console.log(`!! getting wamos contract`);
  const addr = ah.getWamosArtifact().address;
  const wamos = await hre.ethers.getContractAt("src/WamosV2.sol:WamosV2", addr);
  return wamos;
}

async function getArena() {
  console.log(`!! getting arena contract`);
  const addr = ah.getArenaArtifact().address;
  const arena = await hre.ethers.getContractAt(
    "src/WamosV2Arena.sol:WamosV2Arena",
    addr
  );
  return arena;
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

async function getLinkToken() {
  const activeChain = hre.network.name;
  const linkAddr = config.networks[activeChain]["linkToken"];
  console.log(`Getting Link Token on ${activeChain}`);
  const LinkToken = await ethers.getContractAt("LinkToken", linkAddr);
  return LinkToken;
}

module.exports = {
  getWamos,
  getArena,
  getVrf,
  getLinkToken,
};
