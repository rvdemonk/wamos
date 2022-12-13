import React, { useEffect } from "react";
import "../app.css";
import { Cell } from "./Cell";

export function Grid({ state, makeActive, stageWamoMove }) {
  useEffect(() => {}, []);
  return (
    <div className="a-middle a-center x-center y-center">
      <table>
        <tbody>
          {state.grid &&
            state.grid.map((row, i1) => {
              return (
                <tr>
                  {row.map((item, i2) => {
                    return (
                      <td>
                        <Cell
                          state={state}
                          iden={i1 * state.grid_size + i2}
                          coord={i1 + i2}
                          makeActive={makeActive}
                          stageWamoMove={(targetId) => stageWamoMove(targetId)}
                        ></Cell>
                      </td>
                    );
                  })}
                </tr>
              );
            })}
        </tbody>
      </table>
    </div>
  );
}
