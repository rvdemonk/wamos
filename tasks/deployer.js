task("deployer", "Logs the address of the main Signer")
  .setAction(async (taskArgs, hre) => {
    const deployer = await hre.ethers.getSigner();
    console.log(deployer.address);
  })