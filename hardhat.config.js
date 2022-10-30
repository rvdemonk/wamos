require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");
require("hardhat-preprocessor");
const fs = require("fs");

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
    hardhat: {},
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/kWeTCth5hJ-QGN09UW8XRLduAsGpSFA1",
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/eYgXsBSOPz9oR2j30eumjxLssbFSvo6i",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
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
