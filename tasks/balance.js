task("balance", "Balance of mumbai test matic in deployer wallet")
  .setAction(async (taskArgs, hre) => {
    const active = await hre.network.name;
    const deployer = await hre.ethers.getSigner();
    const balance = await hre.ethers.provider.getBalance(deployer.address);
    console.log((balance/10**18).toString().substring(0,5), "MATIC");
  })