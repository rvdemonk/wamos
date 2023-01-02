import React, { useState } from "react";
import Card from "react-bootstrap/Card";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { hexToInt } from "../utilities/HexToInt";
import { CardHeader } from "./CardHeader";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
export function Lobby() {
  const { theme } = useTheme();
  const { connectWamos, gameId, gameData } = useArena();

  const [validated, setValidated] = useState(false);

  const handleSubmit = (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);

    const a = parseInt(formData.get("a"));
    const b = parseInt(formData.get("b"));
    const c = parseInt(formData.get("c"));

    if (a && b && c) {
      connectWamos([a, b, c]);
    }
  };

  return (
    <>
      <CardHeader
        cardHeader={"The Staking Pits of the Wolf God"}
        eraseButton={"arena"}
      />
      <Card.Body className="d-grid gap-2 d-xxl-flex justify-content-center">
        <Form noValidate validated={validated} onSubmit={handleSubmit}>
          <Form.Group className="mb-3" controlId="formAddressl">
            <Form.Label>Game: {hexToInt(gameId)}</Form.Label>

            <Form.Control required name="a" placeholder="Enter Wam0 A" />
          </Form.Group>
          <Form.Group className="mb-3" controlId="formAddressl">
            <Form.Control required name="b" placeholder="Enter Wam0 B" />
          </Form.Group>
          <Form.Group className="mb-3" controlId="formAddressl">
            <Form.Control required name="c" placeholder="Enter Wam0 C" />
            <Form.Text className="text-muted">Pick your Wam0s</Form.Text>
          </Form.Group>

          <Button variant="primary" className="" size="sm" type="submit">
            Stake
          </Button>
        </Form>
      </Card.Body>
    </>
  );
}
