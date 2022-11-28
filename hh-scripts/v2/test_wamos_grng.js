const hre = require("hardhat");
const { deployWamos } = require("./helpers");

const TEST_SEED = 72984518589826227531578991903372844090998219903258077796093728159832249402700;

async function main() {
  if (hre.network.name !== "hardhat") {
    throw "Script not being run on hardhat local network!!";
  }

  console.log("Testing WamosV2 Gaussian RNG!");
  const wamos = await deployWamos();

  // rng config
  const mu = 128;
  const sigma = 96;
  const n = 100;

  const tx = await wamos.gaussianRNG(TEST_SEED, n, mu, sigma);

  const receipt = await tx.wait();
  const event = requestReceipt.events.find(
    (event) => event.event === "GaussianRNGOutput"
  );
  const [results] = requestEvent.args;

  console.log(results);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
