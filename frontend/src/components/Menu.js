import React, { useEffect } from "react";
import { Loading } from "./Loading";
export function Menu({ state, createGame, isBattleStakingApproved }) {
  function Buttons() {
    return (
      <div className="article">
        <form
          className="article-nest a-middle a-center"
          onSubmit={(event) => {
            event.preventDefault();
            const formData = new FormData(event.target);
            const to = formData.get("to");
            const party = formData.get("party");
            if (to && party) {
              createGame(to, party);
            }
          }}
        >
          <div className="address-input a-center a-middle">
            <input
              type="text"
              name="to"
              onfocus="this.value=''"
              required
            ></input>
            <span id="default"> . Player2</span>
          </div>
          <div className="address-input a-top a-center">
            <input type="text" name="party"></input>
            <span id="default"> . Party Size</span>
          </div>

          <div className="address-input a-bottom a-center">
            <input type="submit" value="Create Game"></input>
          </div>
        </form>
      </div>
    );
  }

  return <Buttons />;
}
