import { createContext, useContext, useState, useEffect } from "react";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";

const EthContext = createContext({});

export function useEth() {
  return useContext(EthContext);
}

export function EthProvider({ children }) {
  const [address, setAddress] = useLocalStorage("address");
  const [refresh, setRefresh] = useState(false);

  window.onload = () => {
    checkConnection();
  };

  useEffect(() => {
    window.ethereum.on("accountsChanged", checkConnection);
  }, []);

  async function checkConnection() {
    ethereum
      .request({ method: "eth_accounts" })
      .then(handleAccountsChanged)
      .catch(console.error);
  }

  function handleAccountsChanged(accounts) {
    console.log(accounts);
    !accounts.length
      ? setAddress(false)
      : setAddress(accounts[accounts.length - 1]);
  }

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
    <EthContext.Provider
      value={{
        address,
        connectWallet,
        disconnectWallet,
        checkConnection,
        refresh,
        setRefresh,
      }}
    >
      {children}
    </EthContext.Provider>
  );
}
