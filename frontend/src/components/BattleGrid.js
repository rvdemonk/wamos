import React, { useEffect } from "react";
import "../app.css";
import { Loading } from "./Loading";
import { Status } from "./Status";
import { Grid } from "./Grid";
import { CommitTurn } from "./CommitTurn";
import { BattleGridHead } from "./BattleGridHead";
import { BattleGridFoot } from "./BattleGridFoot";

export function BattleGrid({
  state,
  commitTurn,
  updateWamos,
  expandProfile,
  makeActive,
  stageWamoMove,
}) {
  useEffect(() => {
    if (state.gameStatus === 1 && state.wamoGroup) {
      updateWamos();
    }
  });

  if (!state.wamoGroupReady) {
    return <Loading />;
  } else {
    return (
      <div className="battlegrid">
        <BattleGridHead state={state} />
        <Status
          state={state}
          expanded={state.expanded}
          expandProfile={expandProfile}
        />
        <Grid
          state={state}
          makeActive={makeActive}
          stageWamoMove={(targetId) => stageWamoMove(targetId)}
        />

        <CommitTurn
          state={state}
          commitTurn={(
            targetWamoId,
            moveChoice,
            abilityChoice,
            isMoved,
            moveBeforeAbility,
            useAbility
          ) =>
            commitTurn(
              targetWamoId,
              moveChoice,
              abilityChoice,
              isMoved,
              moveBeforeAbility,
              useAbility
            )
          }
        />
        <BattleGridFoot state={state} />
      </div>
    );
  }
}
