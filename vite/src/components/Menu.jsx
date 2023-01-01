import Card from "react-bootstrap/Card";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
import { CardHeader } from "./CardHeader";
export function Menu() {
  const { theme } = useTheme();
  const { join, setJoin, create, setCreate } = useArena();
  return (
    <>
      <CardHeader cardHeader={"The Gates of the Arena"} />
      <Card.Body className="d-grid gap-2 d-sm-flex justify-content-sm-center">
        <button
          className="btn btn-outline-primary"
          onClick={() => setJoin(!join)}
        >
          Join Game
        </button>

        <button
          className="btn btn-outline-primary"
          onClick={() => setCreate(!create)}
        >
          Create Game
        </button>
      </Card.Body>
    </>
  );
}
