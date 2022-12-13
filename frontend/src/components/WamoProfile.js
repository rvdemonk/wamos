import React from "react";

export function WamoProfile({ expanded, expandProfile, turnCount, wamo }) {
  const traits = wamo.traits;
  const abilities = wamo.abilities;
  const turnColour = !wamo.isPlayer1 ? "commit-p1" : "commit-p2";

  const profile = "profile " + turnColour + " x-center y-center";

  function WamoStatus() {
    return (
      <div className="wamoStatus x-center y-center">
        <h1>Wamo : {wamo.id}</h1>
        <h3>
          Health :{" "}
          <span id="health">
            {wamo.health.toString()}/{traits.health.toString()}
          </span>
        </h3>
        <h3>
          Mana :{" "}
          <span id="mana">
            {wamo.mana.toString()}/{traits.mana.toString()}
          </span>
        </h3>
        <h3>
          Stamina :{" "}
          <span id="stamina">
            {wamo.stamina.toString()}/{traits.stamina.toString()}
          </span>
        </h3>
      </div>
    );
  }

  function WamoTraits() {
    return (
      <div className="wamoTraits x-center y-center">
        <div>
          <h3>Diety:: {traits.dietyType.toString()}</h3>
        </div>
        <div className="magicTraits">
          <h3>
            magicAtt::<span id="mana">{traits.magicAttack.toString()}</span>
          </h3>
          <h3>
            magicDef::<span id="mana">{traits.magicDefence.toString()}</span>
          </h3>
          <h3>
            manaRegen::<span id="mana">100</span>
          </h3>
        </div>
        <div className="meeleeTraits">
          <h3>
            meeleeAtt::
            <span id="stamina">{traits.meeleeAttack.toString()}</span>
          </h3>
          <h3>
            meeleeDef::
            <span id="stamina">{traits.meeleeDefence.toString()}</span>
          </h3>
          <h3>
            staminaRegen::<span id="stamina">100</span>
          </h3>
        </div>
        <div className="specTraits">
          <h3>luck::{traits.luck.toString()}</h3>
        </div>
      </div>
    );
  }
  function Ability({ ability }) {
    return (
      <tr>
        <td>{ability.dietyType.toString()}</td>
        <td>{ability.damageType.toString()}</td>
        <td>{ability.power.toString()}</td>
        <td>{ability.accuracy.toString()}</td>
        <td>{ability.range.toString()}</td>
        <td>{ability.cost.toString()}</td>
      </tr>
    );
  }

  function WamoAbilities() {
    return (
      <table className="wamoTraits x-center y-center">
        <thead>
          <tr>
            <th>Diety</th>
            <th>Dam.</th>
            <th>Pow.</th>
            <th>Acc.</th>
            <th>Range</th>
            <th>Cost</th>
          </tr>
        </thead>
        <tbody>
          {abilities.map((ability, index) => (
            <Ability key={index} ability={ability} />
          ))}
        </tbody>
      </table>
    );
  }

  function WamoTraitsAndAbilities() {
    if (expanded) {
      return (
        <>
          <WamoTraits traits={traits} />
          <WamoAbilities abilities={abilities} />
        </>
      );
    }
  }

  return (
    <div className={profile} onClick={() => expandProfile()}>
      <WamoStatus />
      <WamoTraitsAndAbilities />
    </div>
  );
}
