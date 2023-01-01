import React, { useState } from "react";
import Container from "react-bootstrap/Container";
import Accordion from "react-bootstrap/Accordion";
import Card from "react-bootstrap/Card";

import InputGroup from "react-bootstrap/InputGroup";
import Button from "react-bootstrap/Button";
import { useTheme } from "../context/ThemeContext";
import { useArena } from "../context/ArenaContext";
import { hexToInt } from "../utilities/HexToInt";
import { showAddress } from "../utilities/ShowAddress";
import { Loading } from "./Loading";
import { CardHeader } from "./CardHeader";
export function Join() {
  const { theme } = useTheme();
  const { challenges, joinGame } = useArena();
  const [player1Link, setPlayer1Link] = useState(false);
  const [player2Link, setPlayer2Link] = useState(false);

  function HandleLink({ player, players }) {
    const playerLink = !player ? player1Link : player2Link;
    const playerName = !player ? "Player1: " : "Player2: ";
    const playerAddress = players[player];
    const setPlayerLink = !player ? setPlayer1Link : setPlayer2Link;

    return (
      <a
        href="#"
        className="pe-auto"
        style={{ textDecoration: "none" }}
        onClick={() => setPlayerLink(!playerLink)}
      >
        <h6>
          <small className="text-muted">
            {playerLink
              ? playerName + hexToInt(playerAddress)
              : playerName + showAddress(hexToInt(playerAddress))}
          </small>
        </h6>
      </a>
    );
  }

  function ChallengeCards({ direction }) {
    const challengeList =
      direction === "sent"
        ? challenges?.challengesSentData || []
        : challenges?.challengesReceivedData || [];

    return (
      <Card>
        <Card.Header>Challenges {direction}</Card.Header>
        <Card.Body>
          {!challengeList.length ? (
            <Loading />
          ) : (
            challengeList.map((game) => (
              <Accordion defaultActiveKey={hexToInt(game[0])}>
                <Accordion.Item eventKey={hexToInt(game[0])}></Accordion.Item>
                <Accordion.Header>Game: {hexToInt(game[0])}</Accordion.Header>
                <Accordion.Body>
                  <>
                    <HandleLink player={0} players={game[1].players} />
                    <HandleLink player={1} players={game[1].players} />
                    <h6>
                      <small className="text-muted">
                        Create Time: {hexToInt(game[1].createTime)}
                      </small>
                    </h6>
                    <h6>
                      <small className="text-muted">
                        Status:{" "}
                        {!hexToInt(game[1].status)
                          ? "PREGAME"
                          : hexToInt(game[1].status) < 2
                          ? "ONFOOT"
                          : "fINISHED"}
                      </small>
                    </h6>

                    <Button
                      size="sm"
                      onClick={() => joinGame(direction, hexToInt(game[0]))}
                    >
                      join
                    </Button>
                  </>
                </Accordion.Body>
              </Accordion>
            ))
          )}
        </Card.Body>
      </Card>
    );
  }

  return (
    <>
      <CardHeader cardHeader={"The Gates of the Arena"} eraseButton={arena} />
      <Container className="py-2 d-grid gap-2 d-sm-flex justify-content-sm-center">
        <ChallengeCards direction={"sent"} />
        <ChallengeCards direction={"received"} />
      </Container>
    </>
  );
}
