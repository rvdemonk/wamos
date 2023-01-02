task("wallet", "Displays the address and balance of main wallet")
  .setAction(async (taskArgs, hre) => {
    const network = hre.network.name;
    const units = ['mumbai', 'polygon'].includes(network) ? "MATIC" : "ETH";
    const signer = await hre.ethers.getSigner();
    const balanceRaw = await hre.ethers.provider.getBalance(signer.address);
    const balanceNice = (balanceRaw/10**18).toString().substring(0,5);
    console.log(signer.address);
    console.log(balanceNice, units, `(${network})`);
})