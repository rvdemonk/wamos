task("wallet", "Displays the address and balance of main wallet")
  .setAction(async (taskArgs, hre) => {
    const network = hre.network.name;
    const signer = await hre.ethers.getSigner();
    console.log(network);
  })