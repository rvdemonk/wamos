import { createContext, useContext, useEffect, useState } from "react";
import { useEth } from "./EthContext";
import { useWamo } from "./WamoContext";
import { useSpawn } from "./SpawnContext";
import { useLocalStorage, eraseLocalStorage } from "../hooks/useLocalStorage";
import { hexToInt } from "../utilities/HexToInt";

const ArenaContext = createContext({});

export function useArena() {
  return useContext(ArenaContext);
}

export function ArenaProvider({ children }) {
  const { address } = useEth();
  const { wamos, arena } = useWamo();

  const [arenaStakingStatus, setArenaStakingStatus] = useState(false);
  const [arenaStakingQuery, setArenaStakingQuery] = useState(false);
  const [approving, setApproving] = useState(false);
  const [create, setCreate] = useState(false);
  const [join, setJoin] = useState(false);
  const [gameQuery, setGameQuery] = useState(false);
  const [gameData, setGameData] = useState({});
  const [gameId, setGameId] = useState(false);
  const [isPlayer1, setIsPlayer1] = useState(false);
  const [challenges, setChallenges] = useState(false);
  const [stakedQuery, setStakedQuery] = useState(false);
  const [turned, setTurned] = useState(false);
  const [joinRefresh, setJoinRefresh] = useState(false);
  const [wamoPositions, setWamoPositions] = useState({});
  const [wamoStatus, setWamoStatus] = useState({});
  const [wamoTraits, setWamoTraits] = useState({});
  const [wamoAbilities, setWamoAbilities] = useState({});
  const [wamoMoves, setWamoMoves] = useState({});

  const params = {
    gasLimit: "1122744",
    gasPrice: "8000000000",
  };
  // General UseEffect
  useEffect(() => {
    !arenaStakingStatus ? fetchArenaStakingStatus() : null;
    join && address ? getChallenges() : null;
    gameData && gameData.status > 0 ? getArenaData() : null;
  }, [arenaStakingStatus, join, gameId, gameData, turned, joinRefresh]);

  // Arena Staking Approved UseEffect
  useEffect(() => {
    wamos.on("ArenaStakingApproved", (arenaStakeStatus) => {
      setArenaStakingStatus(arenaStakeStatus);
    });
  }, [arenaStakingQuery]);

  // Create Game UseEffect
  useEffect(() => {
    arena.on("GameCreated", (gameId) => {
      getGame(gameId);
    });
  }, [gameQuery]);

  useEffect(() => {
    console.log(stakedQuery);
  }, [stakedQuery]);

  // useEffect(() => {
  //   arena.on("WamosConnected", (gameId) => {
  //     getGameData(gameId);
  //   });
  // }, [stakedQuery]);

  async function fetchArenaStakingStatus() {
    wamos
      .isApprovedForAll(address, arena.address)
      .then((value) => setArenaStakingStatus(value))
      .catch(console.error);
  }

  async function approveArenaStaking() {
    wamos
      .approveArenaStaking(true, params)
      .then(setArenaStakingQuery(true))
      .catch(console.error);
  }

  function joinGame(direction, index) {
    setGameData(
      direction === "sent"
        ? challenges.challengesSentData[index][1]
        : challenges.challengesReceivedData[index][1]
    );
    setGameId(
      direction === "sent"
        ? challenges.challengesSentData[index][0]
        : challenges.challengesReceivedData[index][0]
    );

    setIsPlayer1(direction === "sent" ? true : false);
  }

  async function getGame(gameId) {
    setGameId(gameId);
    getGameData(gameId);
  }

  async function getGameData(gameId) {
    arena
      .getGameDataStruct(gameId)
      .then((value) => setGameData(value))
      .catch(console.error);
  }

  async function createGame(opponent, party) {
    arena
      .createGame(opponent, party)
      .then(setGameQuery(true))
      .catch(console.error);
  }

  async function getChallenges() {
    try {
      const challengesReceived = await arena.getChallengers(address);
      let challengesReceivedData = [];
      const challengesSent = await arena.getChallenges(address);
      let challengesSentData = [];

      if (challengesReceived.length) {
        for (let i = 0; i < challengesReceived.length; ) {
          challengesReceivedData[i] = [
            challengesReceived[i],
            await arena.getGameDataStruct(challengesReceived[i]),
          ];
          i++;
        }
      }
      if (challengesSent.length) {
        for (let i = 0; i < challengesSent.length; ) {
          challengesSentData[i] = [
            challengesSent[i],
            await arena.getGameDataStruct(challengesSent[i]),
          ];
          i++;
        }
      }

      setChallenges({ challengesReceivedData, challengesSentData });
    } catch (error) {
      console.log(error);
    }
  }

  function getArenaData() {
    for (let i = 0; i < gameData.party1.length; ) {
      getWamoPosition(gameData.party1[i]);
      getWamoStatus(gameData.party1[i]);
      !Object.keys(wamoTraits).length
        ? getWamoTraits(gameData.party1[i])
        : wamoTraits,
        !Object.keys(wamoAbilities).length
          ? getWamoAbilities(gameData.party1[i])
          : wamoAbilities,
        !Object.keys(wamoMoves).length
          ? getWamoMoves(gameData.party1[i])
          : wamoMoves,
        i++;
    }
    for (let i = 0; i < gameData.party2.length; ) {
      getWamoPosition(gameData.party2[i]);
      getWamoStatus(gameData.party2[i]);
      !Object.keys(wamoTraits).length
        ? getWamoTraits(gameData.party2[i])
        : wamoTraits,
        !Object.keys(wamoAbilities).length
          ? getWamoAbilities(gameData.party2[i])
          : wamoAbilities,
        !Object.keys(wamoMoves).length
          ? getWamoMoves(gameData.party2[i])
          : wamoMoves,
        i++;
    }
  }

  async function getWamoPosition(wamoId) {
    // called constantly
    arena
      .getWamoPosition(wamoId)
      .then((value) => addWamoPositions(wamoId, value))
      .catch(console.error);
  }

  function addWamoPositions(wamoId, value) {
    var _wamoPositions = wamoPositions;
    _wamoPositions[wamoId] = value;
    setWamoPositions(_wamoPositions);
  }

  async function getWamoStatus(wamoId) {
    arena
      .getWamoStatus(wamoId)
      .then((value) => addWamoStatus(wamoId, value))
      .catch(console.error);
  }

  function addWamoStatus(wamoId, value) {
    var _wamoStatus = wamoStatus;
    _wamoStatus[wamoId] = value;
    setWamoStatus(_wamoStatus);
  }

  async function getWamoTraits(wamoId) {
    // called once
    wamos
      .getTraits(wamoId)
      .then((value) => addWamoTraits(wamoId, value))
      .catch(console.error);
  }

  function addWamoTraits(wamoId, value) {
    var _wamoTraits = wamoTraits;
    _wamoTraits[wamoId] = value;
    setWamoTraits(_wamoTraits);
  }

  async function getWamoAbilities(wamoId) {
    wamos
      .getAbilities(wamoId)
      .then((value) => addWamoAbilities(wamoId, value))
      .catch(console.error);
  }

  function addWamoAbilities(wamoId, value) {
    var _wamoAbilities = wamoAbilities;
    _wamoAbilities[wamoId] = value;
    setWamoAbilities(_wamoAbilities);
  }

  async function getWamoMoves(wamoId) {
    wamos
      .getMovements(wamoId)
      .then((value) => addWamoMoves(wamoId, value))
      .catch(console.error);
  }

  function addWamoMoves(wamoId, value) {
    var _wamoMoves = wamoMoves;
    _wamoMoves[wamoId] = value;
    setWamoMoves(_wamoMoves);
  }

  async function connectWamos(wamoIds) {
    arena
      .connectWamos(gameId, wamoIds, params)
      .then(setStakedQuery(true))
      .catch(console.error);
  }

  async function commitTurn(turnData) {
    arena
      .commitTurn(gameId, ...turnData, params)
      .then(setTurned(true))
      .catch(console.error);
  }

  function eraseArenaData() {
    setGameId(false);
    setGameData(false);
    setCreate(false);
    setJoin(false);
    setChallenges(false);
    setWamoPositions({});
    setWamoStatus({});
  }

  return (
    <ArenaContext.Provider
      value={{
        arenaStakingStatus,
        approveArenaStaking,
        approving,
        challenges,
        create,
        createGame,
        commitTurn,
        connectWamos,
        eraseArenaData,
        gameData,
        gameId,
        isPlayer1,
        join,
        joinGame,
        setJoin,
        setCreate,
        setGameData,
        setGameId,
        wamoPositions,
        wamoStatus,
      }}
    >
      {children}
    </ArenaContext.Provider>
  );
}
