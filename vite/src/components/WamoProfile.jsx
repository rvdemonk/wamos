import React from "react";
import Table from "react-bootstrap/Table";
import { hexToInt } from "../utilities/HexToInt";

export function WamoProfile({ data }) {
  const id = data?.id || false;
  const traits = data?.traits || false;
  const abilities = data?.abilities || false;

  function WamoStatus() {
    return (
      <Table striped size="sm">
        <tbody>
          <tr>
            <td>Wamo</td>
            <td> {hexToInt(id)}</td>
          </tr>
          <tr>
            <td>Health</td>
            <td> {hexToInt(traits.health)}</td>
          </tr>
          <tr>
            <td>Stamina</td>
            <td> {hexToInt(traits.stamina)}</td>
          </tr>
          <tr>
            <td>Mana</td>
            <td> {hexToInt(traits.mana)}</td>
          </tr>
        </tbody>
      </Table>
    );
  }

  function BaseWamoStatus() {}

  function WamoTraits() {
    return (
      <Table striped size="sm">
        <tbody>
          <tr>
            <td>Diety</td>
            <td> {hexToInt(traits.diety)}</td>
          </tr>

          <tr className="meeleeTraits">
            <td>MeeleeAttack</td>
            <td>
              <span>{hexToInt(traits.meeleeAttack)}</span>
            </td>
          </tr>
          <tr>
            <td>MeeleeDefence</td>
            <td>
              <span>{hexToInt(traits.meeleeDefence)}</span>
            </td>
          </tr>
          <tr>
            <td>StaminaRegen</td>
            <td>
              <span>{hexToInt(traits.staminaRegen)}</span>
            </td>
          </tr>
          <tr className="magicTraits">
            <td>MagicAttack</td>
            <td>
              <span>{hexToInt(traits.magicAttack)}</span>
            </td>
          </tr>
          <tr>
            <td>MagicDefence</td>
            <td>
              <span>{hexToInt(traits.magicDefence)}</span>
            </td>
          </tr>
          <tr>
            <td>ManaRegen</td>
            <td>
              <span>{hexToInt(traits.manaRegen)}</span>
            </td>
          </tr>

          <tr>
            <td>Luck</td>
            <td>{hexToInt(traits.luck)}</td>
          </tr>
          <tr>
            <td>Fecundity</td>
            <td>{hexToInt(traits.fecundity)}</td>
          </tr>
        </tbody>
      </Table>
    );
  }
  function Ability({ ability }) {
    return (
      <tr>
        <td>{hexToInt(ability.dietyType)}</td>
        <td>{hexToInt(ability.damageType)}</td>
        <td>{hexToInt(ability.power)}</td>
        <td>{hexToInt(ability.accuracy)}</td>
        <td>{hexToInt(ability.range)}</td>
        <td>{hexToInt(ability.cost)}</td>
      </tr>
    );
  }

  function WamoAbilities() {
    return (
      <Table striped size="sm">
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
      </Table>
    );
  }

  function WamoTraitsAndAbilities() {
    return (
      <>
        <WamoStatus />
        <WamoTraits traits={traits} />
        <WamoAbilities abilities={abilities} />
      </>
    );
  }

  if (traits && abilities) {
    return (
      <div>
        <WamoTraitsAndAbilities />
      </div>
    );
  }
}
