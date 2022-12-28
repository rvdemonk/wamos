import {
  Badge,
  Button,
  Container,
  Nav,
  Navbar as NavbarBs,
} from "react-bootstrap";
import { NavLink } from "react-router-dom";
import { useEth } from "../context/EthContext";
import { useTheme } from "../context/ThemeContext";
import { showAddress } from "../utilities/ShowAddress";

export function Navbar() {
  const { address, connectWallet, disconnectWallet } = useEth();
  const { theme, setTheme } = useTheme();

  return (
    <NavbarBs
      className={
        theme
          ? "bg-dark navbar-dark shadow-lg"
          : "bg-light navbar-light shadow-sm"
      }
    >
      <Container>
        <Nav className="me-auto">
          <Nav.Link to={"/"} as={NavLink}>
            Wam0s
            <span
              className={theme ? "badge bg-dark" : "badge bg-light text-dark"}
            >
              V2
            </span>
          </Nav.Link>

          {/* <Nav.Link to={"/spawn"} as={NavLink}>
            Spawn
          </Nav.Link>
          <Nav.Link to={"/arena"} as={NavLink}>
            Arena
          </Nav.Link>
          <Nav.Link to={"/guide"} as={NavLink}>
            Guide
          </Nav.Link> */}
        </Nav>

        <label className="form-check-label me-3" htmlFor="lightSwitch ">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            fill={theme ? "white" : "black"}
            onClick={() => setTheme(!theme)}
            className="bi bi-brightness-high"
            viewBox="0 0 16 16"
          >
            <path d="M8 11a3 3 0 1 1 0-6 3 3 0 0 1 0 6zm0 1a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z"></path>
          </svg>
        </label>

        <Button
          onClick={() => (!address ? connectWallet() : disconnectWallet())}
          variant={theme ? "outline-light" : "outline-dark"}
        >
          {!address ? "Connect" : showAddress(address)}
        </Button>
      </Container>
    </NavbarBs>
  );
}
