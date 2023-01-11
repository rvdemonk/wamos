import {
  createContext,
  useContext,
  useDeferredValue,
  useEffect,
  useState,
} from "react";
import { useEth } from "./EthContext";
import { useWamo } from "./WamoContext";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";

const SpawnContext = createContext({});

export function useSpawn() {
  return useContext(SpawnContext);
}

export function SpawnProvider({ children }) {
  const { address, refresh, setRefresh } = useEth();
  const { wamos, arena } = useWamo();

  const [checkCount, setCheckCount] = useState(0);

  const [spawnData, setSpawnData] = useState({});
  const [galData, setGalData] = useState({});
  const [galQuery, setGalQuery] = useState(false);
  const [spawnDataQuery, setSpawnDataQuery] = useState(false);
  const [tokenCount, setTokenCount] = useState(false);
  const [mintPrice, setMintPrice] = useState(false);
  const [requestQuery, setRequestQuery] = useState(false);
  const [requestData, setRequestData] = useState(false);
  const [completeQuery, setCompleteQuery] = useState(false);
  const [spawnStatus, setSpawnStatus] = useState(false);

  const [spawnRequestFulfilled, setSpawnRequestFulfilled] = useState(false);

  const params = {
    value: "1000000000000000",
    gasLimit: "1122744",
    gasPrice: "8000000000",
  };

  useEffect(() => {
    if (address) {
      initialize();
    }
  }, []);

  useEffect(() => {
    console.log(galData);
  }, [galQuery]);

  useEffect(() => {
    if (spawnData.firstWamoData) {
      setSpawnStatus("completed");
    }
  }, [spawnDataQuery]);

  useEffect(() => {
    wamos.on(
      "SpawnRequested",
      (buyerAddress, requestId, firstWamoId, number) => {
        var _spawnData = spawnData;
        _spawnData.lastRequestId = requestId;
        _spawnData.testWamoId = firstWamoId;
        _spawnData.console = [`Wamo ID: ${firstWamoId}`];
        setSpawnData(_spawnData);
        setCheckCount(1);
      }
    );
  }, [spawnStatus]);

  useEffect(() => {
    checkCount ? requestCheck() : null;
  }, [checkCount]);

  useEffect(() => {
    wamos.on(
      "SpawnCompleted",
      (buyerAddress, requestId, firstWamoId, number) => {
        setSpawnWamoData(firstWamoId);
      }
    );
  }, [completeQuery]);

  async function initialize() {
    initializeSpawnData();
    initializeWamoOwnerData();
  }
  async function initializeSpawnData() {
    wamos
      .nextWamoId()
      .then((value) => setTokenCount(value - 1))
      .catch(console.error);

    wamos
      .mintPrice()
      .then((value) => setMintPrice(value))
      .catch(console.error);
  }

  async function initializeWamoOwnerData() {
    try {
      for (let i = 3; i < tokenCount + 1; i++) {
        var _galData = galData;
        _galData[i] = await getSpawnWamoData(i);
        console.log(_galData);
        setGalData(_galData);
      }
      setGalQuery(true);
    } catch (ex) {
      console.log(ex);
    }
  }
  async function requestSpawn(numberToSpawn) {
    wamos
      .requestSpawn(numberToSpawn, params)
      .then(setSpawnStatus("requesting"))
      .catch(console.error);
  }

  async function requestCheck() {
    setInterval(setCheckCount(checkCount + 1), 500);
    try {
      let requestData = await wamos.getRequest(spawnData.lastRequestId);
      setSpawnRequestFulfilled(requestData.isFulfilled);

      if (!spawnRequestFulfilled) {
        requestData = await wamos.getRequest(spawnData.lastRequestId);

        setSpawnRequestFulfilled(requestData.isFulfilled);
      } else {
        setCheckCount(false);
        setSpawnStatus("requested");
      }
    } catch (error) {
      console.log(error);
    }
  }

  async function completeSpawn() {
    wamos
      .completeSpawn(spawnData.lastRequestId)
      .then(() => {
        setSpawnStatus("completing");
        setCompleteQuery(true);
      })
      .catch(console.error);
  }

  async function setSpawnWamoData(id) {
    try {
      const owner = await wamos.ownerOf(id);
      const abilities = await wamos.getAbilities(id);
      const traits = await wamos.getTraits(id);
      var _spawnData = spawnData;
      _spawnData.firstWamoData = { id, owner, abilities, traits };
      setSpawnData(_spawnData);
      setSpawnDataQuery(true);
    } catch {
      console.error;
    }
  }

  async function getSpawnWamoData(id) {
    try {
      const owner = await wamos.ownerOf(id);
      const abilities = await wamos.getAbilities(id);
      const traits = await wamos.getTraits(id);
      return { id, owner, abilities, traits };
    } catch {
      console.error;
    }
  }

  function eraseSpawnData() {
    eraseLocalStorage("spawnStatus");
    setSpawnStatus(false);
  }
  return (
    <SpawnContext.Provider
      value={{
        spawnStatus,
        spawnData,
        requestSpawn,
        completeSpawn,
        eraseSpawnData,
        getSpawnWamoData,
        checkCount,
        mintPrice,
        tokenCount,
      }}
    >
      {children}
    </SpawnContext.Provider>
  );
}
