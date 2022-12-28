import { createContext, useContext, useState } from "react";
import { ethers } from "ethers";
import WamosV2ArenaArtifact from "../contracts/WamosV2Arena.json";
import WamosV2ArenacontractAddress from "../contracts/WamosV2Arena-contract-address.json";
import WamosV2Artifact from "../contracts/WamosV2.json";
import WamosV2contractAddress from "../contracts/WamosV2-contract-address.json";

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
      WamosV2contractAddress.WamosV2,
      WamosV2Artifact.abi,
      provider.getSigner(0)
    );

    setWamos(wamos);

    // init arena contract
    const arena = new ethers.Contract(
      WamosV2ArenacontractAddress.WamosV2Arena,
      WamosV2ArenaArtifact.abi,
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
