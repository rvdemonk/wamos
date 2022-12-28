import React, { useState } from "react";
import Card from "react-bootstrap/Card";
import Form from "react-bootstrap/Form";
import InputGroup from "react-bootstrap/InputGroup";
import Button from "react-bootstrap/Button";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
export function Create() {
  const { theme } = useTheme();
  const { createGame } = useArena();

  const [validated, setValidated] = useState(false);

  const handleSubmit = (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);
    const to = formData.get("to");
    const party = formData.get("party");
    if (to && party) {
      createGame(to, party);
    }
  };

  return (
    <>
      <Card.Body className="d-grid gap-2 d-xxl-flex justify-content-center">
        <Form noValidate validated={validated} onSubmit={handleSubmit}>
          <Form.Group className="mb-3" controlId="formAddressl">
            <Form.Label>Opponent Address</Form.Label>

            <Form.Control
              required
              type="address"
              name="to"
              placeholder="Enter opponent address"
            />
          </Form.Group>

          <Form.Group className="mb-3" controlId="formParty">
            <Form.Label>Party Size</Form.Label>

            <Form.Control
              required
              type="party-size"
              name="party"
              placeholder="Party size"
            />
            <Form.Text className="text-muted">
              This will be the size of your team
            </Form.Text>
          </Form.Group>

          <Button variant="primary" className="" size="sm" type="submit">
            Create Game
          </Button>
        </Form>
      </Card.Body>
    </>
  );
}
