import React, { useEffect } from "react";
import { Loading } from "./Loading";

export function ApproveBattleStaking({
  state,
  approveBattleStaking,
  isBattleStakingApproved,
}) {
  useEffect(() => {
    if (state.P1Address) {
      isBattleStakingApproved();
    }
  }, [state.hasApprovedStaking, state.submitStake]);

  if (!state.wamosv1) {
    return <Loading />;
  } else {
    return (
      <div className="article">
        <div className="a-middle a-center x-center y-center">
          <button className="gen-button" onClick={() => approveBattleStaking()}>
            <h1>Approve Battle Staking</h1>
          </button>

          <button className="gen-button" onClick={() => approveBattleStaking()}>
            <h2>&#128214;</h2>
          </button>
        </div>
      </div>
    );
  }
}
