import { createContext, useContext, useState } from "react";
import { ethers } from "ethers";

import artifacts from "../artifacts.json";

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
      artifacts.WamosV2Address,
      artifacts.WamosV2ABI.abi,
      provider.getSigner(0)
    );

    setWamos(wamos);

    // init arena contract
    const arena = new ethers.Contract(
      artifacts.WamosV2ArenaAddress,
      artifacts.WamosV2ArenaABI.abi,
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
