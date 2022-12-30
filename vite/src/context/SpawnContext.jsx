import { createContext, useContext, useEffect, useState } from "react";
import { useEth } from "./EthContext";
import { useWamo } from "./WamoContext";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";

const SpawnContext = createContext({});

export function useSpawn() {
  return useContext(SpawnContext);
}

export function SpawnProvider({ children }) {
  const { address } = useEth();
  const { wamos, arena } = useWamo();

  const [checkCount, setCheckCount] = useState(false);
  const [spawnData, setSpawnData] = useState(false);
  const [spawnStatus, setSpawnStatus] = useLocalStorage("spawnStatus");
  const [spawnRefresh, setSpawnRefresh] = useState(false);
  const [spawnRequestFulfilled, setSpawnRequestFulfilled] = useState(false);

  useEffect(() => {
    !spawnRefresh ? initializeSpawnData() : null;
    checkCount ? requestCheck() : null;
  }, [checkCount, spawnRefresh]);

  async function initializeSpawnData() {
    try {
      const tokenCount = (await wamos.nextWamoId()) - 1;
      const mintPrice = await wamos.mintPrice();
      const spawnData = { tokenCount, mintPrice };
      setSpawnData(spawnData);
      setSpawnRefresh(true);
    } catch (ex) {
      console.log(ex);
    }
  }
  async function requestSpawn(numberToSpawn) {
    // const WAMOSV2_PRICE = ethers.utils.parseEther("0.001");
    // const GAS_LIMIT = ethers.utils.parseEther("0.0000000000001");
    setSpawnStatus("requesting");

    const params = {
      value: "1000000000000000",
      gasLimit: "1122744",
      gasPrice: "8000000000",
    };
    let requestEvent;
    try {
      // send request
      const requestTx = await wamos.requestSpawn(numberToSpawn, params);

      // get request details from tx event
      const receipt = await requestTx.wait();
      requestEvent = receipt.events.find(
        (event) => event.event === "SpawnRequested"
      );

      const [buyerAddress, requestId, firstWamoId, number] = requestEvent.args;

      var _spawnData = spawnData;

      _spawnData.lastRequestId = requestId;

      _spawnData.testWamoId = firstWamoId;
      _spawnData.console = [`Wamo ID: ${firstWamoId}`];
      setSpawnData(_spawnData);
      setCheckCount(1);
    } catch (error) {
      console.log(error);
    }
  }

  async function requestCheck() {
    try {
      setCheckCount(checkCount + 1);
      let requestData = await wamos.getRequest(spawnData.lastRequestId);
      setSpawnRequestFulfilled(requestData.isFulfilled);

      if (!spawnRequestFulfilled) {
        requestData = await wamos.getRequest(spawnData.lastRequestId);
        await new Promise((r) => setTimeout(r, 1000));

        setSpawnRequestFulfilled(requestData.isFulfilled);
      } else {
        console.log(`Request Fulfilled!`);
        setCheckCount(false);
        setSpawnStatus("requested");
      }
    } catch (error) {
      console.log(error);
    }
  }

  async function completeSpawn() {
    try {
      const requestId = spawnData.lastRequestId;
      console.log(`** Completing spawn with requestId ${requestId}`);

      // send complete spawn transaction
      const completeTx = await wamos.completeSpawn(requestId);

      // set state
      setSpawnStatus("completing");

      console.log(`Getting tx receipt`);
      const receipt = await completeTx.wait();
      const completionEvent = receipt.events.find(
        (event) => event.event === "SpawnCompleted"
      );

      // const [, , firstWamoId, lastWamoId] = completionEvent.args;

      const firstWamoId = spawnData.testWamoId;

      console.log(`Wam0 id: ${firstWamoId}`);

      var _spawnData = spawnData;

      const id = firstWamoId;
      const abilities = await wamos.getAbilities(firstWamoId);
      const traits = await wamos.getTraits(firstWamoId);

      _spawnData.firstWamoData = { id, abilities, traits };
      setSpawnData(_spawnData);

      setSpawnStatus("completed");
    } catch (error) {
      console.log(error);
    }
  }

  function eraseSpawnData() {
    eraseLocalStorage("spawnStatus");
    setSpawnStatus(false);
    setSpawnData(false);
    setSpawnRefresh(false);
  }
  return (
    <SpawnContext.Provider
      value={{
        spawnStatus,
        spawnData,
        requestSpawn,
        completeSpawn,
        eraseSpawnData,
        checkCount,
      }}
    >
      {children}
    </SpawnContext.Provider>
  );
}
