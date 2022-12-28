import Card from "react-bootstrap/Card";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
export function Approve() {
  const { theme } = useTheme();
  const { approveArenaStaking } = useArena();
  return (
    <>
      <Card.Body>
        <Card.Title>Approval is required to stake Wam0s</Card.Title>
        <Card.Text>This is a one time transaction per address</Card.Text>
        <button
          className="btn btn-outline-primary"
          onClick={() => approveArenaStaking()}
        >
          Approve
        </button>
      </Card.Body>
    </>
  );
}
