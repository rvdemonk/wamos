import { Button, Container } from "react-bootstrap";
import { NavLink } from "react-router-dom";
import { useTheme } from "../context/ThemeContext";

export function Home() {
  const { theme } = useTheme();
  return (
    <div
      className={
        theme ? "bg-gradient-dark text-light container" : "bg-light container"
      }
    >
      <div className="py-5 text-center vh-100">
        <h1 className="display-5 fw-bold">Wam0s</h1>
        <div className="col-lg-6 mx-auto">
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
