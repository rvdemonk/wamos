task("mint", "Mints Wamos")
  .addParam("amount", "The Wamo's ID number")
  .setAction(async (taskArgs, hre) => {
    const utils = require("../scripts/utils/");

    if (taskArgs.amount > 10) {
      console.log(`You cannot mint that many Wamos at once!`);
    }
    const price = hre.config.wamosMintPrice;
    if (utils.callers.getDeployerBalance() < taskArgs.amount * price) {
      console.log(`Insufficient funds`);
    }
    console.log(`-- Starting mint`);
    const signer = await hre.ethers.getSigner();
    await utils.callers.mint(taskArgs.amount, signer.address);
  });
