import { createContext, useContext } from "react";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";

const EthContext = createContext({});

export function useEth() {
  return useContext(EthContext);
}

export function EthProvider({ children }) {
  const [address, setAddress] = useLocalStorage("address");

  async function connectWallet() {
    try {
      const [P1] = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      setAddress(P1);
    } catch (ex) {
      console.log(ex);
    }
  }

  function disconnectWallet() {
    eraseLocalStorage("address");
    setAddress(false);
  }

  return (
    <EthContext.Provider value={{ address, connectWallet, disconnectWallet }}>
      {children}
    </EthContext.Provider>
  );
}
