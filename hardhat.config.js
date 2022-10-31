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
  defaultNetwork: "hardhat",
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
      linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      url: "https://eth-goerli.g.alchemy.com/v2/kWeTCth5hJ-QGN09UW8XRLduAsGpSFA1",
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon: {
      chainId: 137,
      linkToken: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
      url: "https://polygon-mainnet.g.alchemy.com/v2/NAD4cA_1X57AN5ad43yLzSaVOamH2LSt",
    },
    mumbai: {
      chainId: 80001,
      linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
      url: "https://polygon-mumbai.g.alchemy.com/v2/eYgXsBSOPz9oR2j30eumjxLssbFSvo6i",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  devChains: ["hardhat", "anvil"],
  VERIFICATION_BLOCK_CONFIRMATIONS: 6,
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
