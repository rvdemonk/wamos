const hre = require("hardhat");

async function main() {
  const GridGame = await hre.ethers.getContractFactory("GridGame3");
  const gridgame = await GridGame.deploy();
  const deployed_game = await gridgame.deployed();
  console.log(deployed_game.address);
  console.log(deployed_game.signer.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
