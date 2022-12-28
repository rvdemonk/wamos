import { WamoProfile } from "./WamoProfile";

export function Status({ state, expandProfile }) {
  const wamoGroup = state.wamoGroup;
  const wamoActive = state.wamoActive;
  const turnCount = state.turnCount;
  const expanded = state.expanded;

  if (wamoActive > -1) {
    return (
      <WamoProfile
        expandProfile={expandProfile}
        expanded={expanded}
        turnCount={turnCount}
        wamo={wamoGroup[wamoActive]}
      />
    );
  }
}
