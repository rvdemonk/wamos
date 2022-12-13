import "../app.css";
import React from "react";

export function Welcome({ address }) {
  const [page, setPage] = React.useState(1);

  const user = !address
    ? "unconnected"
    : address.substring(0, 4) + "..." + address.slice(-4);
  return (
    <div className="article">
      <button
        className={
          page > 1 ? "gen-button a-middle a-left y-center x-center" : "none"
        }
        onClick={() => setPage(page - 1)}
      >
        <h1 id="default">&#9664;</h1>
      </button>
      <button
        className={
          page < 4 ? "gen-button a-middle a-right y-center x-center" : "none"
        }
        onClick={() => setPage(page + 1)}
      >
        <h1 id="default">&#9654;</h1>
      </button>
      <div className="a-bottom a-center y-center x-center">
        <h1 id="default">{page}/4</h1>
      </div>

      <>
        {page === 1 && (
          <div className="welcome-article calm-ocean gen-box a-middle a-center">
            <div className="a-middle a-center x-center y-center">
              <h1 className="boujee-text">Welcome, {user}</h1>
              <h2 id="default">The g0ds invite you to play</h2>
            </div>
          </div>
        )}
        {page === 2 && (
          <div className="welcome-article clouds gen-box a-middle a-center"></div>
        )}
        {page === 3 && (
          <div className="welcome-article clouds gen-box a-middle a-center"></div>
        )}
        {page === 4 && (
          <div className="welcome-article clouds gen-box a-middle a-center"></div>
        )}
      </>
    </div>
  );
}
