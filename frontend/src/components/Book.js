import React from "react";
import { useParams } from "react-router-dom";

export function Book() {
  const [page, setPage] = React.useState(1);

  const params = useParams();

  const id = !params.id ? 0 : params.id;

  const traits = {
    health: 111,
    meeleeAttack: 111,
    meeleeDefence: 81,
    magicAttack: 141,
    magicDefence: 195,
    luck: 105,
    stamina: 129,
    mana: 87,
    diety: 7,
    manaRegen: 0,
    staminaRegen: 0,
    fecundity: 0,
  };

  function Traits({ traits }) {
    return (
      <table>
        <tbody>
          <tr>
            <td>Health</td>
            <td>{traits.health.toString()}</td>
          </tr>
          <tr>
            <td>Diety:</td>
            <td>{traits.diety.toString()}</td>
          </tr>
          <tr>
            <td>MeeleeAttack:</td>
            <td>{traits.meeleeAttack.toString()}</td>
          </tr>
          <tr>
            <td>MeeleeDefence:</td>
            <td>{traits.meeleeDefence.toString()}</td>
          </tr>
          <tr>
            <td>MagicAttack:</td>
            <td>{traits.magicAttack.toString()}</td>
          </tr>
          <tr>
            <td>MagicDefence:</td>
            <td>{traits.magicDefence.toString()}</td>
          </tr>
          <tr>
            <td>Luck:</td>
            <td>{traits.luck.toString()}</td>
          </tr>
          <tr>
            <td>Mana:</td>
            <td>{traits.mana.toString()}</td>
          </tr>
          <tr>
            <td>ManaRegen:</td>
            <td>{traits.manaRegen.toString()}</td>
          </tr>
          <tr>
            <td>Stamina:</td>
            <td>{traits.stamina.toString()}</td>
          </tr>
          <tr>
            <td>StaminaRegen:</td>
            <td>{traits.staminaRegen.toString()}</td>
          </tr>
          <tr>
            <td>Fecundity:</td>
            <td>{traits.fecundity.toString()}</td>
          </tr>
        </tbody>
      </table>
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

  function Abilities({ abilities }) {
    return (
      <table>
        <thead>
          <tr>
            <th>Diety Type</th>
            <th>Damage Type</th>
            <th>Power</th>
            <th>Accuracy</th>
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

  return (
    <div className="article">
      <div className="book a-middle a-center">
        {page === 1 && (
          <div className="page">
            <div className="wamo-title">
              <h1>Wamo: {id} </h1>
              <p>Owned by</p>
            </div>
          </div>
        )}
        {page === 2 && (
          <div className="page">
            <div className="wamo-title">
              <h1>Traits</h1>
            </div>
            <div className="wamo-traits1">
              <Traits traits={traits} />
            </div>
          </div>
        )}
        {page === 3 && (
          <div className="page">
            <h1>Ability</h1>
            <p>This is the content of page 3.</p>
          </div>
        )}
        {page === 4 && (
          <div className="page">
            <h1>Glory</h1>
            <p>This is the content of page 4.</p>
          </div>
        )}
        <div className="controls">
          <button
            onClick={() => setPage(1)}
            className={page === 1 ? "active" : ""}
          >
            Wamo
          </button>
          <button
            onClick={() => setPage(2)}
            className={page === 2 ? "active" : ""}
          >
            traits
          </button>
          <button
            onClick={() => setPage(3)}
            className={page === 3 ? "active" : ""}
          >
            Abilities
          </button>
          <button
            onClick={() => setPage(4)}
            className={page === 4 ? "active" : ""}
          >
            Glory
          </button>
        </div>
      </div>
    </div>
  );
}
