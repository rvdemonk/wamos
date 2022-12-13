import React, { Fragment, useState, useEffect } from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  useOutlet,
  Link,
} from "react-router-dom";

import { Welcome } from "../components/Welcome";
import { WamoSpawner } from "./WamoSpawner";
import { WamoDapp } from "./WamoDapp";
import { WamoGallery } from "../components/WamoGallery";

import "../app.css";

export function App() {
  const [address, setAddress] = useState(false);

  useEffect(() => {
    const isUserConnected = localStorage.getItem("isUserConnected");
    if (isUserConnected === "true") {
      connectWallet();
    }
  }, []);

  async function connectWallet() {
    try {
      const [P1Address] = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      localStorage.setItem("isUserConnected", true);
      localStorage.setItem("P1Address", P1Address);
      setAddress(P1Address);
    } catch (ex) {
      console.log(ex);
    }
  }

  function disconnectWallet() {
    localStorage.setItem("isUserConnected", false);
    localStorage.removeItem("P1Address");
    setAddress(false);
  }

  function ConnectButton() {
    if (!address) {
      return (
        <button
          className="nav-child connect butt"
          onClick={() => connectWallet()}
        >
          <h1 className="connect-text">Connect</h1>
        </button>
      );
    } else {
      return (
        <button
          className="nav-child connect butt"
          onClick={() => disconnectWallet()}
        >
          <h1 className="boujee-text">{`${address.substring(
            0,
            4
          )}...${address.slice(-4)}`}</h1>
        </button>
      );
    }
  }

  function PageNotFound() {
    return <div>404 - Page not found</div>;
  }

  function Head() {
    return (
      <head>
        <title>Woomoos</title>
      </head>
    );
  }

  function NavToggle() {
    return (
      <button className={"nav-child toggle"}>
        <h1 className="nav-text">&#9650;</h1>
      </button>
    );
  }

  function Nav() {
    const smallNav = <div className="small-nav" />;
    if (!address) {
      return (
        <div className="nav">
          <button className={"nav-child nav-text title"}>
            <h1 className="nav-text">Wam0s</h1>
          </button>

          <button className={"nav-child spawn"}>
            <h1 className="nav-text">Spawn</h1>
          </button>

          <button className={"nav-child battle"}>
            <h1 className="nav-text">Battle</h1>
          </button>
          <NavToggle />
          <ConnectButton />
        </div>
      );
    } else {
      return (
        <div className="nav">
          <Link className="link-style" to="/" state={{ address: address }}>
            <button className={"nav-child title"}>
              <h1 className="boujee-text">Wam0s</h1>
            </button>
          </Link>

          <Link
            className="link-style"
            to="/wamomint"
            state={{ address: address }}
          >
            <button className={"nav-child spawn"}>
              <h1 className="nav-text">Spawn</h1>
            </button>
          </Link>

          <Link
            className="link-style"
            to="/wamodapp"
            state={{ address: address }}
          >
            <button className={"nav-child battle"}>
              <h1 className="nav-text">Battle</h1>
            </button>
          </Link>
          <NavToggle />
          <ConnectButton />
        </div>
      );
    }
  }

  function Home() {
    const outlet = useOutlet();

    return (
      <html>
        <Head />
        <body>
          <Nav />
          {outlet || <Welcome address={address} />}
        </body>
      </html>
    );
  }

  return (
    <Router>
      <Routes>
        <Route exact path="/" element={<Home />}>
          <Route
            exact
            path="/wamomint"
            element={<WamoSpawner address={address} />}
          />
          <Route
            exact
            path="/wamodapp"
            element={<WamoDapp address={address} />}
          />
          <Route exact path="/wamo/:id" element={<WamoGallery />} />
          <Route path="*" element={<PageNotFound />} />
        </Route>
      </Routes>
    </Router>
  );
}
