import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
import { useSpawn } from "../context/SpawnContext";
export function CardHeader({ cardHeader, eraseButton }) {
  const { theme } = useTheme();
  const { eraseArenaData } = useArena();
  const { eraseSpawnData } = useSpawn();
  return (
    <Card.Header>
      <Button
        onClick={
          eraseButton === "arena"
            ? () => eraseArenaData()
            : () => eraseSpawnData()
        }
        variant={theme ? "outline-light" : "outline-dark"}
        size="sm"
        className="me-3"
      >
        <span>&#x2715;</span>
      </Button>
      {cardHeader}
    </Card.Header>
  );
}
