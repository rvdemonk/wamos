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
    !arenaStakingStatus ? fetchArenaStakingStatus() : null;
    join && address ? getChallenges() : null;
  }, [join]);

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
    try {
      const challengesReceived = await arena.getChallengers(address);
      let challengesReceivedData = [];
      const challengesSent = await arena.getChallenges(address);
      let challengesSentData = [];

      if (challengesReceived.length) {
        for (let i = 0; i < challengesReceived.length; i++) {
          challengesReceivedData[i] = [
            challengesReceived[i],
            await arena.getGameDataStruct(challengesReceived[i]),
          ];
        }
      }
      if (challengesSent.length) {
        for (let i = 0; i < challengesSent.length; i++) {
          challengesSentData[i] = [
            challengesSent[i],
            await arena.getGameDataStruct(challengesSent[i]),
          ];
        }
      }

      setChallenges({ challengesReceivedData, challengesSentData });
    } catch (error) {
      console.log(error);
    }
  }

  async function getGameDataStruct(gameId) {
    try {
      return await arena.getGameDataStruct(gameId);
    } catch (error) {
      console.log(error);
    }
  }

  function eraseArenaData() {
    setCreate(false);
    setJoin(false);
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
        eraseArenaData,
        gameId,
        setGameId,
        challenges,
      }}
    >
      {children}
    </ArenaContext.Provider>
  );
}
