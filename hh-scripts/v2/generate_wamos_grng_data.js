const hre = require("hardhat");
const fs = require('fs');
const { deployWamos } = require("./helpers");

const TEST_SEED = 123456789;

const writeData = (data, mu, sigma) => {
  const filename = `./data/wamos_grng_${Date.now()
  }.txt`
  const file = fs.createWriteStream(filename);
  file.write(`WamosV2 Gaussian RNG, mu=${mu}, sigma=${sigma}\n`)
  file.on('error', (err) => console.log("# Error writing data to file\n", err));
  data.forEach(datum => {
    file.write(datum.toString() + ', ');
  });
  file.end();
  console.log(`* Dataset saved to ${filename}`);
}

async function main() {
  if (hre.network.name !== "hardhat") {
    throw "Script not being run on hardhat local network!!";
  }

  console.log("Testing WamosV2 Gaussian RNG!");
  const wamos = await deployWamos(saveDeploy=false);

  // rng config
  const mu = 128;
  const sigma = 48;
  const n = 3000;

  const tx = await wamos.gaussianRNG(TEST_SEED, n, mu, sigma);

  const receipt = await tx.wait();
  const event = receipt.events.find(
    (event) => event.event === "GaussianRNGOutput"
  );
  const [results] = event.args;

  console.log(results);
  console.log("Writing data...");
  writeData(results, mu, sigma);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
