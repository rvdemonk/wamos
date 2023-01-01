import { Route, Routes } from "react-router-dom";
import { EthProvider } from "./context/EthContext";
import { WamoProvider } from "./context/WamoContext";
import { ThemeProvider } from "./context/ThemeContext";
import { SpawnProvider } from "./context/SpawnContext";
import { ArenaProvider } from "./context/ArenaContext";
import { Navbar } from "./components/Navbar";
import { Home } from "./pages/Home";
import { Arena } from "./pages/Arena";
import { Spawn } from "./pages/Spawn";
import { Gallery } from "./pages/Gallery";
import { Guide } from "./pages/Guide";

function App() {
  return (
    <EthProvider>
      <WamoProvider>
        <ThemeProvider>
          <SpawnProvider>
            <ArenaProvider>
              <Navbar />
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/spawn" element={<Spawn />} />
                <Route path="/arena" element={<Arena />} />
                <Route path="/gallery" element={<Gallery />} />
                <Route path="/guide" element={<Guide />} />
              </Routes>
            </ArenaProvider>
          </SpawnProvider>
        </ThemeProvider>
      </WamoProvider>
    </EthProvider>
  );
}

export default App;
