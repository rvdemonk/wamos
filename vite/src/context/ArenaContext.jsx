import { createContext, useContext, useEffect, useState } from "react";
import { useEth } from "./EthContext";
import { useWamo } from "./WamoContext";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";

const ArenaContext = createContext({});

export function useArena() {
  return useContext(ArenaContext);
}

export function ArenaProvider({ children }) {
  const { address } = useEth();
  const { wamos, arena } = useWamo();
  const [arenaAddressStatus, setArenaAddressStatus] =
    useLocalStorage("arenaAddressStatus");

  const [arenaStakingStatus, setArenaStakingStatus] =
    useLocalStorage("arenaStakingStatus");

  const [create, setCreate] = useState(false);
  const [join, setJoin] = useState(false);
  const [gameId, setGameId] = useState(false);
  const [challenges, setChallenges] = useState(false);

  const params = {
    gasLimit: "1122744",
    gasPrice: "8000000000",
  };

  useEffect(() => {
    // !arenaAddressStatus
    //   ? setWamosArenaAddress()
    //   : console.log(arenaStakingStatus);
    !arenaStakingStatus ? fetchArenaStakingStatus() : null;
    !Object.keys(challenges).length ? getChallenges() : null;
  }, [arenaStakingStatus, challenges]);

  async function setWamosArenaAddress() {
    await wamos.setWamosArenaAddress(arena.address);
    setArenaAddressStatus(true);
  }

  async function fetchArenaStakingStatus() {
    try {
      const _arenaStakingStatus = await wamos.isApprovedForAll(
        address,
        arena.address
      );

      setArenaStakingStatus(_arenaStakingStatus);
    } catch (error) {
      console.log(error);
    }
  }

  async function approveArenaStaking() {
    try {
      await wamos.approveArenaStaking(params);
      fetchArenaStakingStatus();
    } catch (error) {
      console.log(error);
    }
  }

  async function joinGame() {
    try {
    } catch (error) {
      console.log(error);
    }
  }

  async function createGame(opponent, party) {
    try {
      const _gameId = await arena.createGame(opponent, party);
      setGameId(_gameId);
    } catch (error) {
      console.log(error);
    }
  }

  async function getChallenges() {
    const challengesReceived = await arena.getChallengesReceivedBy(address);
    const challengesSent = await arena.getChallengesSentBy(address);
    console.log(challengesSent);

    setChallenges({ challengesReceived, challengesSent });
  }

  return (
    <ArenaContext.Provider
      value={{
        arenaStakingStatus,
        approveArenaStaking,
        join,
        setJoin,
        joinGame,
        create,
        setCreate,
        createGame,
        gameId,
      }}
    >
      {children}
    </ArenaContext.Provider>
  );
}
