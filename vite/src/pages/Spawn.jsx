import { useSpawn } from "../context/SpawnContext";
import { useTheme } from "../context/ThemeContext";
import Button from "react-bootstrap/Button";
import Card from "react-bootstrap/Card";
import { Loading } from "../components/Loading";

import { WamoProfile } from "../components/WamoProfile";
import { NotConnected } from "../components/NotConnected";

export function Spawn() {
  const {
    spawnStatus,
    spawnData,
    requestSpawn,
    completeSpawn,
    eraseSpawnData,
    checkCount,
    checkMod,
    mintPrice,
    tokenCount,
  } = useSpawn();

  const { theme } = useTheme();

  function Render() {
    const showPrice = mintPrice || "...";

    if (!spawnStatus) {
      return (
        <>
          <div className="card-body">
            <h5 className="card-title">{tokenCount || "..."} Wam0s spawned</h5>
            <p className="card-text">
              With a mint price of: {showPrice.toString()}
            </p>
            <button
              onClick={() => requestSpawn("1")}
              className="btn btn-outline-primary"
            >
              Spawn
            </button>
          </div>
        </>
      );
    } else if (["requesting"].includes(spawnStatus)) {
      return (
        <>
          <div className="card-body">
            <h5 className="card-title">Communicating with the G0ds...</h5>
            {!spawnData.console ? (
              <Loading />
            ) : (
              spawnData.console.map((item, index) => (
                <>
                  <p key={index} className="text-muted">
                    {item}
                  </p>
                  {checkCount ? (
                    <p key={index + 1} className="text-muted">
                      Innocent Victims Sacrificed: {checkCount}
                    </p>
                  ) : null}
                </>
              ))
            )}
          </div>
        </>
      );
    } else if (["completing"].includes(spawnStatus)) {
      return (
        <>
          <div className="card-body">
            <h5 className="card-title">Communicating with the G0ds...</h5>
            <Loading />
          </div>
        </>
      );
    } else if (spawnStatus === "requested") {
      return (
        <>
          <div className="card-body">
            <h5 className="card-title">Complete...</h5>
            <p className="card-text">...the g0ds are waiting</p>
            <button
              onClick={() => completeSpawn()}
              className="btn btn-outline-primary"
            >
              Complete
            </button>
          </div>
        </>
      );
    } else if (spawnStatus === "completed") {
      return (
        <>
          <div className="card-body">
            <WamoProfile data={spawnData.firstWamoData} />
          </div>
        </>
      );
    }
  }

  return (
    <div className="container">
      <div className="py-4 vh-100 text-center">
        <Card className={theme ? "bg-dark text-light" : "bg-light"}>
          <Card.Header>
            <Button
              onClick={() => eraseSpawnData()}
              variant={theme ? "outline-light" : "outline-dark"}
              size="sm"
              className="me-3"
            >
              <span>&#x2715;</span>
            </Button>
            The cosmic oozepits
          </Card.Header>
          <Render />
        </Card>
      </div>
    </div>
  );
}
