import "../styles/grid.css";
import { useArena } from "../context/ArenaContext";
export function Cell({ index }) {
  const { wamoPositions } = useArena();

  function getKeyByValue(object, value) {
    return Object.keys(object).find((key) => object[key] === value);
  }
  return Object.values(wamoPositions).includes(index) ? (
    Object.values(wamoPositions).indexOf(index) <
    Object.values(wamoPositions).length / 2 ? (
      <div className="player1">{getKeyByValue(wamoPositions, index)}</div>
    ) : (
      <div className="player2">{getKeyByValue(wamoPositions, index)}</div>
    )
  ) : (
    <div className="box"></div>
  );
}
