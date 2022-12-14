task(
  "clear_consumers",
  "Removes all consuming contracts from VRF subscription"
).setAction(async (taskArgs, hre) => {
  const vrf = await require("../scripts/utils/").getters.getVrf();

  const active = await hre.network.name;
  const subId = hre.config.networks[active].subscriptionId;
  let subData = await vrf.getSubscription(subId);
  const consumers = subData.consumers;
  for (let i = 0; i < consumers.length; i++) {
    await vrf.removeConsumer(subId, consumers[i]);
  }
  // // check
  // subData = await vrf.getSubscription(subId);
  // if (subData.consumers.length === 0) {
  //   console.log("success");
  // } else {
  //   console.log("task failed");
  // }
});
