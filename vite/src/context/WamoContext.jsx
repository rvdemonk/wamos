import { createContext, useContext, useState, useEffect } from "react";
import { ethers } from "ethers";

// import artifacts from "../artifacts.json";
import WamosV2 from "../artifacts/WamosV2.json";
import WamosV2Arena from "../artifacts/WamosV2Arena.json";

const WamoContext = createContext({});

export function useWamo() {
  return useContext(WamoContext);
}

export function WamoProvider({ children }) {
  // contract states
  const [wamos, setWamos] = useState(undefined);
  const [arena, setArena] = useState(undefined);
  const [provider, setProvider] = useState(undefined);

  async function initializeContracts() {
    // init provider
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    setProvider(provider);

    // init wamos contract

    const wamos = new ethers.Contract(
      WamosV2.address,
      WamosV2.abi,
      provider.getSigner(0)
    );
    setWamos(wamos);

    // init arena contract
    const arena = new ethers.Contract(
      WamosV2Arena.address,
      WamosV2Arena.abi,
      provider.getSigner(0)
    );
    setArena(arena);
  }

  !wamos && !arena ? initializeContracts() : null;

  return (
    <WamoContext.Provider value={{ wamos, arena, provider }}>
      {children}
    </WamoContext.Provider>
  );
}
