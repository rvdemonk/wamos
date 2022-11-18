require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-preprocessor");
const fs = require("fs");
// TASKS
require("./tasks/link_balance.js");

/** @type import('hardhat/config').HardhatUserConfig */

// facilitates interoperability between hh and forge lib
function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

module.exports = {
  WAMOS_DEPLOY_ADDR: "0x5c4980F343F2726aDe2bCe1D45c93d46B660d1B5",
  WAMOS_BATTLE_ADDR: "0x82398ABcd2Fd713a21d9eD799486c1Ba65c101DA",
  defaultNetwork: "mumbai",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    mainnet: {
      chainId: 1,
      linkToken: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
      url: "",
    },
    goerli: {
      chainId: 5,
      accounts: [process.env.PRIVATE_KEY],
      linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      url: "https://eth-goerli.g.alchemy.com/v2/kWeTCth5hJ-QGN09UW8XRLduAsGpSFA1",
      vrfCoordinator: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
      gasLane:
        "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
    },
    polygon: {
      chainId: 137,
      linkToken: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
      url: "https://polygon-mainnet.g.alchemy.com/v2/NAD4cA_1X57AN5ad43yLzSaVOamH2LSt",
      vrfCoordinator: "",
      gasLane: "",
    },
    mumbai: {
      chainId: 80001,
      accounts: [process.env.PRIVATE_KEY, process.env.PRIVATE_KEY2],
      linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      url: "https://polygon-mumbai.g.alchemy.com/v2/eYgXsBSOPz9oR2j30eumjxLssbFSvo6i",
      gas: 2100000,
      gasPrice: 8000000000,
      subscriptionId: 2476,
      vrfCoordinator: "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed",
      gasLane:
        "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f",
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: "91IE9SEC9VWW3I8I3YH27H6JFSUISRZ87K",
    },
  },
  devChains: ["hardhat", "anvil"],
  VERIFICATION_BLOCK_CONFIRMATIONS: 6,
  WAMOSV1_PRICE: "1000000000000000",
  preprocess: {
    eachLine: (hre) => ({
      transform: (line) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
    }),
  },
  paths: {
    sources: "./src",
    cache: "./cache_hardhat",
    artifacts: "./client/artifacts",
  },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    },
  },
};
