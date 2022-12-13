import React, { Fragment, useEffect, useState } from "react";
import "../app.css";

export function Cell({ state, iden, coord, makeActive, stageWamoMove }) {
  const wamoGroup = state.wamoGroup;
  const wamoActive = state.wamoActive;
  const stageWamoMoveIndex = state.stageWamoMoveIndex;
  var moveSquare = undefined;
  var isPlayer1 = state.isPlayer1;

  const showMoves = state.showMoves;

  var wamoParty = [];
  var wamoGridMoves = [];

  for (let i = 0; i < Object.keys(wamoGroup).length; i++) {
    wamoParty[i] = wamoGroup[i].position;
    wamoGridMoves.push(...wamoGroup[i].gridMoves);
  }

  var wamo = undefined;
  var wamoClass = "box-a";
  var wamoId = undefined;
  var gridNumber = "";
  var isWamo = false;
  var isShow = false;
  var wamoStage = false;

  if (wamoParty.includes(iden)) {
    isWamo = true;
    wamo = wamoParty.indexOf(iden);
    wamoClass = wamoGroup[wamo].className;
    wamoId = wamoGroup[wamo].id;
  } else if (
    wamoActive > -1 &&
    wamoGroup[wamoActive].gridMoves.includes(iden)
  ) {
    isShow = true;

    gridNumber = wamoGroup[wamoActive].gridMoves.indexOf(iden);
  }

  if (showMoves && isShow) {
    return (
      <div className={"showMove"} onClick={(iden) => stageWamoMove(iden)}>
        <h1 className="tiny-text">{gridNumber}</h1>
      </div>
    );
  } else if (isWamo) {
    return (
      <div className={wamoClass} onClick={() => makeActive(wamo)}>
        <h1 className="tiny-text">{wamoActive === wamo ? wamoId : ""}</h1>
      </div>
    );
  } else {
    return <div className={wamoClass}></div>;
  }
}
