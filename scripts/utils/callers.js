const hre = require("hardhat");
const getters = require("./getters");

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function registerLatestArena() {
  const wamos = await getWamos();
  const artifacts = getArtifacts();
  await wamos.setWamosArenaAddress(artifacts.WamosV2ArenaAddress);
}

async function clearVrfConsumers(vrf, subId) {
  let subData = await vrf.getSubscription(subId);
  const consumers = subData.consumers;
  for (let i = 0; i < consumers.length; i++) {
    await vrf.removeConsumer(subId, consumers[i]);
  }
}

function displayWamoTraits(id, traits) {
  console.log(`\n---- Wamo #${id} Traits ----\n`);
  for (const property in traits) {
    if (isNaN(Number(property))) {
      console.log(`${traits[property].toString()} | ${property}`);
    }
  }
}

async function mint(amount, receipient) {
  const wamos = await getters.getWamos();
  const owner = (await hre.ethers.getSigner()).address.toString();
  const params = { value: amount * hre.config.wamosMintPrice };
  console.log(`Requesting spawn...`);

  const requestTx = await wamos.requestSpawn(amount, params);
  const receipt = await requestTx.wait();
  const requestEvent = receipt.events.find(
    (event) => event.event === "SpawnRequested"
  );
  const [sender, requestId, startWamoId, number] = requestEvent.args;

  // console.log(typeof startWamoId, typeof amount,)
  const endId = Number(startWamoId) + Number(amount) - 1;
  console.log(`Request ID ${requestId}`);

  let isFulfilled = await wamos.getRequestStatus(requestId);
  let time = 0;
  const period = 3000;
  console.log(`\n* Entering wait loop`);
  while (!isFulfilled) {
    console.log(` waited ${time / 1000} seconds`);
    time = time + period;
    sleep(period);
    isFulfilled = await wamos.getRequestStatus(requestId);
  }
  console.log(`* Request fulfilled. Completing spawn...`);
  const completeTx = await wamos.completeSpawn(requestId);
  console.log(`\n--- Spawn complete`);
  if (endId > startWamoId) {
    console.log(
      `${owner.substring(0, 6)} spawned Wamos #${startWamoId} to #${endId}`
    );
  } else {
    console.log(`${owner.substring(0, 6)} spawned Wamo #${startWamoId}`);
  }
  return startWamoId;
}

async function getDeployerBalance() {
  const signer = await hre.ethers.getSigner();
  const balanceRaw = await hre.ethers.provider.getBalance(signer.address);
  return balanceRaw;
}

module.exports = {
  registerLatestArena,
  clearVrfConsumers,
  displayWamoTraits,
  mint,
  getDeployerBalance,
};
