import React, { useEffect } from "react";

export function Lobby({
  state,
  id,
  getGameStatus,
  connectWamo,
  playerReady,
  getReadyStatus,
}) {
  useEffect(() => {
    if (state.P1Address) {
    }
  }, [state.gameStatus]);

  return (
    <div className="article">
      <div className="join join-child-center">
        <h1 className="join-text">Stake Your Wam0s</h1>
      </div>
    </div>
  );
}
