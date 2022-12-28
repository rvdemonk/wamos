import React, { useState } from "react";
import Card from "react-bootstrap/Card";
import Form from "react-bootstrap/Form";
import InputGroup from "react-bootstrap/InputGroup";
import Button from "react-bootstrap/Button";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
export function Join() {
  const { theme } = useTheme();
  const { challengesRecieved, challengesSent } = useArena();

  const [validated, setValidated] = useState(false);

  return (
    <>
      <Card.Body className="d-grid gap-2 d-xxl-flex justify-content-center"></Card.Body>
    </>
  );
}
