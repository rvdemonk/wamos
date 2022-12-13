// import '../app.css';

export function CommitTurn({ state, commitTurn }) {
  const turnColour = state.gameData.turnCount % 2 ? "commit-p1" : "commit-p2";
  const commitClass = "commit-turn-box " + turnColour + " a-right a-middle";

  const moveBeforeAbility = formData.get("moveBeforeAbility");

  return (
    <div className={commitClass}>
      <label class="switch">
        <input type="checkbox" name="moveBeforeAbility"></input>
        <span class="slider round"></span>
      </label>
    </div>
  );
}
