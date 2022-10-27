/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  paths: {
    sources: "./src",
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
};
