import { useState } from "react";
import { useWamo } from "../context/WamoContext";
import { useArena } from "../context/ArenaContext";
import { useTheme } from "../context/ThemeContext";
import Button from "react-bootstrap/Button";
import Card from "react-bootstrap/Card";
import Col from "react-bootstrap/Col";

import { Menu } from "../components/Menu";
import { Approve } from "../components/Approve";
import { Create } from "../components/Create";
import { Join } from "../components/Join";

export function Arena() {
  const { theme } = useTheme();

  const [id, setId] = useState(false);

  const { arenaStakingStatus, join, create, eraseArenaData } = useArena();

  function Render() {
    if (!arenaStakingStatus) {
      return <Approve />;
    } else if (!create && !join) {
      return <Menu />;
    } else if (create && !join) {
      return <Create />;
    } else if (!create && join) {
      return <Join />;
    } else if (create && join) {
      return (
        <>
          <Card.Header>The side pits of the W0lf g0d</Card.Header>
          <Card.Body>
            <Card.Title>...escape from here.</Card.Title>
          </Card.Body>
        </>
      );
    }
  }

  return (
    <div className="container">
      <div className="py-4 vh-100 text-center">
        <Card className={theme ? "bg-dark text-light" : "bg-light"}>
          <Card.Header>
            <Button
              onClick={() => eraseArenaData()}
              variant={theme ? "outline-light" : "outline-dark"}
              size="sm"
              className="me-3"
            >
              <span>&#x2715;</span>
            </Button>
            The Gates of the Arena
          </Card.Header>
          <Render />
        </Card>
      </div>
    </div>
  );
}
