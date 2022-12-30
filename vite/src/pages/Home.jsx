import { useState } from "react";
import { Button, Container } from "react-bootstrap";
import { NavLink } from "react-router-dom";
import { showAddress } from "../utilities/ShowAddress";
import { useTheme } from "../context/ThemeContext";
import { useWamo } from "../context/WamoContext";
export function Home() {
  const { theme } = useTheme();
  const { arena, wamos } = useWamo();
  const [wamosLink, setWamosLink] = useState(false);
  const [arenaLink, setArenaLink] = useState(false);

  function handleRef(contract) {
    if (contract === wamos) {
      return `https://mumbai.polygonscan.com/address/${wamos.address}`;
    } else if (contract === arena) {
      return `https://mumbai.polygonscan.com/address/${arena.address}`;
    }
  }

  function HandleLink({ contract }) {
    const contractLink = contract === wamos ? wamosLink : arenaLink;
    const contractName = contract === wamos ? "Wam0s: " : "Arena: ";
    const contractAddress = contract === wamos ? wamos.address : arena.address;
    const setContractLink = contract === wamos ? setWamosLink : setArenaLink;

    return (
      <a
        href="#"
        className="pe-auto"
        style={{ textDecoration: "none" }}
        onClick={() => setContractLink(!contractLink)}
      >
        <h6>
          <small className="text-muted">
            {contractLink
              ? contractName + contractAddress
              : contractName + showAddress(contractAddress)}
          </small>
        </h6>
      </a>
    );
  }

  return (
    <div
      className={
        theme ? "bg-gradient-dark text-light container" : "bg-light container"
      }
    >
      <div className="py-5 text-center vh-100">
        <h1 className="display-5 fw-bold">Wam0s</h1>
        <div className="col-lg-6 mx-auto">
          <HandleLink contract={wamos} />
          <HandleLink contract={arena} />
          <p className="lead mb-4">A Web3 Native Battle Monster Game.</p>
          <div className="d-grid gap-2 d-sm-flex justify-content-sm-center">
            <Button
              to={"/spawn"}
              as={NavLink}
              className="btn btn-sm px-4 gap-3"
              variant={theme ? "primary" : "outline-primary"}
            >
              Spawn
            </Button>
            <Button
              to={"/arena"}
              as={NavLink}
              className="btn btn-sm px-4 gap-3"
              variant={theme ? "danger" : "outline-danger"}
            >
              Arena
            </Button>
            <Button
              to={"/guide"}
              as={NavLink}
              className="btn btn-sm px-4 gap-3"
              variant={theme ? "success" : "outline-success"}
            >
              Guide
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
