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
import { FormExample } from "../components/FormExample";

export function Arena() {
  const { theme } = useTheme();

  const [id, setId] = useState(false);

  const { arenaStakingStatus, join, create } = useArena();

  function Render() {
    if (!arenaStakingStatus) {
      return <Approve />;
    } else if (!create && !join) {
      return <Menu />;
    } else if (create && !join) {
      return <Create />;
    } else if (!create && join) {
      return (
        <>
          <Card.Body>
            <Card.Title>Join Game</Card.Title>
          </Card.Body>
        </>
      );
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
          <Card.Header>The Gates of the Arena</Card.Header>
          <Render />
        </Card>
      </div>
    </div>
  );
}
