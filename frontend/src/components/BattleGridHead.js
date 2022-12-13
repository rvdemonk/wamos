// import '../app.css';

export function BattleGridHead({ state }) {
  const turn =
    state.gameData.turnCount % 2 === 0 ? state.Player1 : state.Player2;
  const turnColour = state.gameData.turnCount % 2 ? "orange" : "blue";
  return (
    <div className="battle-grid-head">
      <>
        <h1 className="tiny-text">
          <span className="blue">{`${state.Player1.substring(
            0,
            4
          )}...${state.Player1.slice(-4)}`}</span>
          <span> vs </span>
          <span className="orange">{`${state.Player2.substring(
            0,
            4
          )}...${state.Player2.slice(-4)}`}</span>
        </h1>
        <h1 className="tiny-text">{`TurnCount #${state.gameData.turnCount}`}</h1>
        <h1 className="tiny-text">
          <span>{`Current Turn: `}</span>
          <span className={turnColour}>{`${turn.substring(0, 4)}...${turn.slice(
            -4
          )} `}</span>
        </h1>
      </>
    </div>
  );
}
