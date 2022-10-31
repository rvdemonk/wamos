const networkConfig = {
  1: {
    name: "mainnet",
    linkToken: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
  },
  5: {
    name: "goerli",
    linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
  },
  137: {
    name: "polygon",
    linkToken: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
  },
  80001: {
    name: "mumbai",
    linkToken: "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
  },
};

const devChains = ["hardhat", "anvil"];
const VERIFICATION_BLOCK_CONFIRMATIONS = 6;

module.exports = {
  networkConfig,
  devChains,
};
