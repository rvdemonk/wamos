import React, { useEffect } from "react";
import { Loading } from "./Loading";
export function Join({
  state,
  joinGameSent,
  joinGameReceived,
  updateChallenges,
}) {
  useEffect(() => {
    if (state.challengesSent && state.challengesReceived) {
      updateChallenges();
    } else {
      <Loading />;
    }
  }, []);

  function Sent() {
    if (state.challengesSent.length) {
      return (
        <div>
          {state.challengesSent.map((item, index) => {
            return (
              <div>
                <div
                  className="spec-button"
                  onClick={() => joinGameSent(index)}
                >
                  <h3>{`Join Game ${item}`}</h3>
                </div>
              </div>
            );
          })}
        </div>
      );
    }
  }

  function Recieved() {
    if (state.challengesReceived.length) {
      return (
        <div>
          {state.challengesReceived.map((item, index) => {
            return (
              <div>
                <div
                  className="spec-button"
                  onClick={() => joinGameReceived(index)}
                >
                  <h3>{`Join Game ${item}`}</h3>
                </div>
              </div>
            );
          })}
        </div>
      );
    }
  }

  return (
    <div className="article-join">
      <div className="gen-box received">
        <h1>Received</h1>

        <Recieved />
      </div>
      <div className="gen-box sent">
        <h1>Sent</h1>

        <Sent />
      </div>
    </div>
  );
}
