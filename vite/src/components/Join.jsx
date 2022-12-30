import React, { useState } from "react";
import Container from "react-bootstrap/Container";
import Accordion from "react-bootstrap/Accordion";
import Card from "react-bootstrap/Card";
import Form from "react-bootstrap/Form";
import Spinner from "react-bootstrap/Spinner";
import InputGroup from "react-bootstrap/InputGroup";
import Button from "react-bootstrap/Button";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";

import { hexToInt } from "../utilities/HexToInt";
export function Join() {
  const { theme } = useTheme();
  const { challenges } = useArena();

  const [validated, setValidated] = useState(false);

  function Loading() {
    return (
      <Spinner animation="border" role="status">
        <span className="visually-hidden">Loading...</span>
      </Spinner>
    );
  }

  return (
    <Container className="py-2 d-grid gap-2 d-sm-flex justify-content-sm-center">
      <Card>
        <Card.Header>Challenges Sent</Card.Header>
        <Card.Body>
          {!challenges.challengesSent ? (
            <Loading />
          ) : (
            challenges.challengesSent.map((gameId) => (
              <Accordion defaultActiveKey={hexToInt(gameId)}>
                <Accordion.Item eventKey={hexToInt(gameId)}></Accordion.Item>
                <Accordion.Header variant="success">
                  {hexToInt(gameId)}
                </Accordion.Header>
                <Accordion.Body>{hexToInt(gameId)}</Accordion.Body>
              </Accordion>
            ))
          )}
        </Card.Body>
      </Card>
    </Container>
  );
}
