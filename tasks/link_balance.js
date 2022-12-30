task("link_balance", "Displays balance of link in deployment wallet").setAction(
  async (taskArgs, hre) => {
    const ethers = hre.ethers;

    const account = await ethers.getSigner();
    const activeChain = network.name;
    const linkTokenAddr = config.networks[activeChain]["linkToken"];

    // artifact not found
    const LinkToken = await ethers.getContractFactory("lib/chainlink/contracts/src/v0.8/LinkToken");

    const linkTokenContract = new ethers.Contract(
      linkTokenAddr,
      LinkToken.interface,
      account
    );

    const balHex = await linkTokenContract.balanceOf(account);
    const bal = ethers.BigNumber.from(balHex._hex).toString();

    console.log(
      `LINK balance of account ${account} is ${bal / Math.pow(10, 18)}`
    );
  }
);
