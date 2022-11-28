const hre = require("hardhat");
const { deployWamos } = require("./helpers");

const TEST_SEED = 123456789;

async function main() {
  if (hre.network.name !== "hardhat") {
    throw "Script not being run on hardhat local network!!";
  }

  console.log("Testing WamosV2 Gaussian RNG!");
  const wamos = await deployWamos();

  // rng config
  const mu = 128;
  const sigma = 48;
  const n = 1000;

  const tx = await wamos.gaussianRNG(TEST_SEED, n, mu, sigma);

  const receipt = await tx.wait();
  const event = receipt.events.find(
    (event) => event.event === "GaussianRNGOutput"
  );
  const [results] = event.args;

  console.log(results);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
