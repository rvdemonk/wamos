const { task } = require("hardhat/config");

task("fund_subscription", "Funds the vrf subscription with the link in the main deployers wallet")
.setAction(async (taskArgs, hre) => {
    const active = await hre.network.name;
    const vrf = await require("../scripts/helpers").getVrf();
    const subId = hre.config.networks[active].subscriptionId;
    let subData = await vrf.getSubscription(subId);
    
  })