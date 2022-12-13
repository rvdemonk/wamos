// import '../app.css';

export function CommitTurn({ state, commitTurn }) {
  const turnColour = state.gameData.turnCount % 2 ? "commit-p1" : "commit-p2";
  const commitClass = "commit-turn-box " + turnColour + " a-right a-middle";
  return (
    <form
      className={commitClass}
      onSubmit={(event) => {
        // This function just calls the transferTokens callback with the
        // form's data.
        event.preventDefault();

        const formData = new FormData(event.target);

        const targetWamoId = formData.get("targetWamoId");
        const moveChoice = formData.get("moveChoice");
        const abilityChoice = formData.get("abilityChoice");
        const isMoved = formData.get("isMoved");
        const moveBeforeAbility = formData.get("moveBeforeAbility");
        const useAbility = formData.get("useAbility");

        if (
          targetWamoId &&
          moveChoice &&
          abilityChoice &&
          isMoved &&
          moveBeforeAbility &&
          useAbility
        ) {
          commitTurn(
            targetWamoId,
            moveChoice,
            abilityChoice,
            isMoved,
            moveBeforeAbility,
            useAbility
          );
        }
      }}
    >
      <div className="commit-turn-input">
        <label for="move">Move: </label>
        <select id="move" name="moveChoice">
          <option value="0">0</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="4">4</option>
          <option value="5">5</option>
          <option value="6">6</option>
          <option value="7">7</option>
        </select>
      </div>
      <div className="commit-turn-input">
        <label for="targetWamoId">TargetWamoId: </label>
        <select id="targetWamoId" name="targetWamoId">
          <option value="0">{state.wamoGroup[0].id}</option>
          <option value="1">{state.wamoGroup[1].id}</option>
          <option value="2">{state.wamoGroup[2].id}</option>
          <option value="3">{state.wamoGroup[3].id}</option>
        </select>
      </div>
      <div className="commit-turn-input">
        <label for="ability">Choose Ability: </label>
        <select id="ability" name="abilityChoice">
          <option value="0">0</option>
          <option value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
        </select>
      </div>

      <div className="commit-turn-input">
        <label for="isMoved">Move at all?: </label>
        <select id="isMoved" name="isMoved">
          <option value="true">Yes</option>
          <option value="false">No</option>
        </select>
      </div>

      <div className="commit-turn-input">
        <label for="moveBeforeAbility">Move before Ability?: </label>
        <select id="moveBeforeAbility" name="moveBeforeAbility">
          <option value="true">Yes</option>
          <option value="false">No</option>
        </select>
      </div>
      <div className="commit-turn-input">
        <label for="useAbility">Use Ability?: </label>
        <select id="useAbility" name="useAbility">
          <option value="true">Yes</option>
          <option value="false">No</option>
        </select>
      </div>
      <div className="commit-turn-input">
        <input type="submit" value="Commit Turn" fontSize="25px"></input>
      </div>
    </form>
  );
}
