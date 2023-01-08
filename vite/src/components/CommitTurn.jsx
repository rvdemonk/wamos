import React, { useState } from "react";
import Container from "react-bootstrap/Container";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import { hexToInt } from "../utilities/HexToInt";
import { CardHeader } from "./CardHeader";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
export function CommitTurn() {
  const { gameData, commitTurn } = useArena();

  const [validated, setValidated] = useState(false);

  const handleSubmit = (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);
    const actingWamoId = parseInt(formData.get("actingWamoId"));
    const targetWamoId = parseInt(formData.get("targetWamoId"));
    const moveSelection = parseInt(formData.get("moveSelection"));
    const abilitySelection = parseInt(formData.get("abilitySelection"));
    const isMoved = formData.get("isMoved");
    const moveBeforeAbility = formData.get("moveBeforeAbility");
    const useAbility = formData.get("useAbility");

    if (
      actingWamoId &&
      targetWamoId &&
      moveSelection &&
      abilitySelection &&
      isMoved &&
      moveBeforeAbility &&
      useAbility
    ) {
      const turnData = [
        actingWamoId,
        targetWamoId,
        moveSelection,
        abilitySelection,
        isMoved,
        moveBeforeAbility,
        useAbility,
      ];
      commitTurn(turnData);
    }
  };

  return (
    <Container>
      <Form noValidate validated={validated} onSubmit={handleSubmit}>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Label>Commit Turn: {hexToInt(gameData.turnCount)}</Form.Label>

          <Form.Control
            required
            name="actingWamoId"
            size="sm"
            placeholder="Enter actingWamoId"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="targetWamoId"
            size="sm"
            placeholder="Enter targetWamoId"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="moveSelection"
            size="sm"
            placeholder="Enter moveSelection"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="abilitySelection"
            size="sm"
            placeholder="Enter abilitySelection"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="isMoved"
            size="sm"
            placeholder="Enter isMoved"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="moveBeforeAbility"
            size="sm"
            placeholder="Enter moveBeforeAbility"
          />
        </Form.Group>
        <Form.Group className="mb-3" controlId="formAddressl">
          <Form.Control
            required
            name="useAbility"
            size="sm"
            placeholder="Enter useAbility"
          />
        </Form.Group>

        <Button variant="secondary" className="" size="sm" type="submit">
          Commit
        </Button>
      </Form>
    </Container>
  );
}
