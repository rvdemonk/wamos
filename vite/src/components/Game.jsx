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
import { showAddress } from "../utilities/ShowAddress";

export function Game() {
  const { theme } = useTheme();

  return (
    <Container className="py-2 d-grid gap-2 d-sm-flex justify-content-sm-center">
      <ChallengeCards direction={"sent"} />
      <ChallengeCards direction={"received"} />
    </Container>
  );
}
