import { useTheme } from "../context/ThemeContext";
import { useSpawn } from "../context/SpawnContext";
import { CardHeader } from "./CardHeader";
import { Loading } from "./Loading";
import { WamoProfile } from "./WamoProfile";
import Container from "react-bootstrap/Container";
import Card from "react-bootstrap/Card";
import Accordion from "react-bootstrap/Accordion";
import Button from "react-bootstrap/Button";
import { hexToInt } from "../utilities/HexToInt";
import { showAddress } from "../utilities/ShowAddress";
export function GalleryList({ header }) {
  const { theme } = useTheme();
  const { getSpawnWamoData, spawnData } = useSpawn();
  console.log(spawnData);
  return (
    <Container animation="border" role="status">
      <Card className={theme ? "bg-dark text-light" : "bg-light"}>
        <CardHeader cardHeader={"All Wam0s"} eraseButton={"wamos"} />

        <Card.Body>
          <Loading />
        </Card.Body>
      </Card>
    </Container>
  );
}
