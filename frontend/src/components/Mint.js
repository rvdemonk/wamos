import { useEffect } from "react";
import { WamoProfile } from "./WamoProfile";

export function Mint({
  state,
  mintRequest,
  mintSpawn,
  mintSpawnId,
  spawnedWamoData,
  resetMintData,
}) {
  useEffect(() => {
    if (state.P1Address) {
      // updateLobby();
      console.log("00");
    }
  }, [state.mintInProgress, state.mintComplete]);

  const spawnId = (event) => {
    event.preventDefault();
    const formData = new FormData(event.target);
    const wamoId = formData.get("to");
    if (wamoId) {
      mintSpawnId(wamoId);
    }
  };

  function MintButton() {
    if (!state.mintInProgress) {
      return (
        <div className="article">
            <button className="article-button" onClick={mintRequest}>
              <h1 className="join-text">
                Spawn a Wam0
              </h1>
            </button>
        </div>
      );
    }
    if (!state.mintComplete && state.mintInProgress) {
      return (
        <div className="article">
          <h3 className="join-text">
            You requested: Wam0 #{state.tokenId.toNumber()}
          </h3>
          <button className="article-button" onClick={mintSpawn}>
            <h1 className="join-text">Complete Sacrifice? </h1>
          </button>
        </div>
        
      );
    }
    if (state.mintComplete && state.mintInProgress) {
      const wamoId = state.tokenId.toNumber()
      return (
        <div className="article">
          <div>
            <h2 className="join-text">Spawn Complete!</h2>
            <h3 className="join-text">
              You own: Wam0 #{wamoId}
            </h3>
            <WamoProfile 
              wamoId={wamoId}
              traits={null}
              abilities={null}
            />
            <h3 className="join-text">Check the console for Wam0 Data</h3>
            <button className="article-button" onClick={resetMintData}>
              <h1 className="join-text">Spawn Again? </h1>
            </button>
          </div>
        </div>
      );
    }
  }

  return <MintButton />;
}