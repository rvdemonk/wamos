const hre = require("hardhat");

const getContracts = async () => {
  const wamosAddress = hre.config.WAMOS_DEPLOY_ADDR;
  const battleAddress = hre.config.WAMOS_BATTLE_ADDR;

  const wamos = hre.ethers.getContractAt("WamosV1", wamosAddress);
  const battle = hre.ethers.getContractAt("WamosBattleV1", battleAddress);

  return [wamos, battle];
};

const getWamos = async () =>
  hre.ethers.getContractAt("WamosV1", hre.config.WAMOS_DEPLOY_ADDR);

const getWamosBattle = async () =>
  hre.ethers.getContractAt("WamosBattleV1", hre.config.WAMOS_BATTLE_ADDR);

module.exports = { getWamos, getWamosBattle };
