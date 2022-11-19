async function main() {
  const [p1, p2] = await hre.ethers.getSigners();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
