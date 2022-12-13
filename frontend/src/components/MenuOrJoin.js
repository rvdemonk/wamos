import React, { useEffect } from "react";
export function MenuOrJoin({ toggleMenuCreate, toggleMenuJoin }) {
  return (
    <div className="article-join">
      <button
        className="gen-button join y-center"
        onClick={() => toggleMenuJoin()}
      >
        <h1>Join</h1>
      </button>
      <button
        className="gen-button create y-center"
        onClick={() => toggleMenuCreate()}
      >
        <h1>Create</h1>
      </button>
    </div>
  );
}
