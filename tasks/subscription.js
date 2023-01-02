
task("subscription", "Logs the balance enjoyed by the vrf subscription")
.setAction(async (taskArgs, hre) => {
    const { getVrf } = require("../scripts/helpers");
    const active = await hre.network.name;
    const vrf = await getVrf();
    const subId = hre.config.networks[active].subscriptionId;
    const subData = await vrf.getSubscription(subId);
    const balance = (subData.balance / 10**18).toString().substring(0,5);
    console.log(`Sub ID ${subId} |`, balance, "LINK");
    
    console.log(subData);
  })