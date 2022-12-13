// import '../app.css';

import React, { useEffect } from "react";

export function BattleGridFoot({ state }) {
  const turn =
    state.gameData.turnCount % 2 === 0 ? state.Challenger : state.Challengee;
  const turnColour = state.gameData.turnCount % 2 ? "orange" : "blue";
  return (
    <div className="battle-grid-foot">
      <h1 className="tiny-text">events</h1>
    </div>
  );
}
