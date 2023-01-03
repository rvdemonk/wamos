import React, { useState } from "react";
import Container from "react-bootstrap/Container";
import Table from "react-bootstrap/Table";
import { Cell } from "./Cell";
import { CommitTurn } from "./CommitTurn";
import { GalleryList } from "./GalleryList";
import { useArena } from "../context/ArenaContext";

import Card from "react-bootstrap/Card";

import { CardHeader } from "./CardHeader";
export function Game() {
  const { gameData, wamoPositions } = useArena();

  const gridSize = 16;
  let a = new Array(gridSize);
  for (let i = 0; i < gridSize; ++i) a[i] = 0;

  return (
    <>
      <CardHeader cardHeader={"The Arena"} eraseButton={"arena"} />
      <Container className="py-2 d-grid gap-2 d-md-flex justify-content-center ">
        <CommitTurn />
        <table>
          <tbody>
            {a.map((item, row) => (
              <tr>
                {a.map((item2, col) => (
                  <td>
                    <Cell index={row * gridSize + col} />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
        <GalleryList filter={gameData.players} />
      </Container>
    </>
  );
}
