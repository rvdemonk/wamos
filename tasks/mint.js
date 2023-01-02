task("mint", "Mints Wamos")
    .addParam("amount", "The Wamo's ID number")
    .setAction(async (taskArgs, hre) => {
        const helpers = require('../scripts/helpers');
        if (taskArgs.amount > 10 ) {
            console.log(`You cannot mint more than 10 Wamos at once!`);
        }
        const price = hre.config.wamosMintPrice;
        if (helpers.getDeployerBalance() < taskArgs.amount*price) {
            console.log(`Insufficient funds`);
        }
        console.log(`-- Starting mint`)
        await helpers.mint(taskArgs.amount);
    })