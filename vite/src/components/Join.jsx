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
export function Join() {
  const { theme } = useTheme();
  const { challengesRecieved, challengesSent } = useArena();

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
          {!challengesSent ? (
            <Loading />
          ) : (
            challengesSent.map((item) => (
              <Accordion defaultActiveKey={item.id}>
                <Accordion.Item eventKey={item.id}></Accordion.Item>
                <Accordion.Header variant="success">
                  {item.header}
                </Accordion.Header>
                <Accordion.Body>{item.body}</Accordion.Body>
              </Accordion>
            ))
          )}
        </Card.Body>
      </Card>
      <Card>
        <Card.Header>Challenges Received</Card.Header>
        <Card.Body>
          {!challengesSent ? (
            <Loading />
          ) : (
            challengesSent.map((item) => (
              <Accordion defaultActiveKey={item.id}>
                <Accordion.Item eventKey={item.id}></Accordion.Item>
                <Accordion.Header variant="success">
                  {item.header}
                </Accordion.Header>
                <Accordion.Body>{item.body}</Accordion.Body>
              </Accordion>
            ))
          )}
        </Card.Body>
      </Card>
    </Container>
  );
}
