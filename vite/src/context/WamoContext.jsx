import { createContext, useContext, useState } from "react";
import { ethers } from "ethers";
import { isPrivateMode } from "../utilities/isPrivateMode";

import settings from '../artifacts/world.settings.json';
// private world
import WamosV2_private from "../artifacts/private/WamosV2.json";
import WamosV2Arena_private from "../artifacts/private/WamosV2Arena.json";
// public world
import WamosV2_shared from "../artifacts/shared/WamosV2.json";
import WamosV2Arena_shared from "../artifacts/shared/WamosV2Arena.json";

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

    const isPrivateMode = settings.privateMode;
    let WamosV2;
    let WamosV2Arena;

    if (isPrivateMode) {
      WamosV2 = WamosV2_private;
      WamosV2Arena = WamosV2Arena_private;
    } else {
      WamosV2 = WamosV2_shared;
      WamosV2Arena = WamosV2Arena_shared;     
    }
    
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

    console.log("initialized contracts");
  }

  !wamos && !arena ? initializeContracts() : null;

  return (
    <WamoContext.Provider value={{ wamos, arena, provider }}>
      {children}
    </WamoContext.Provider>
  );
}
