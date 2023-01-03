import { useTheme } from "../context/ThemeContext";
import { useSpawn } from "../context/SpawnContext";
import { CardHeader } from "./CardHeader";
import { Loading } from "./Loading";
import Container from "react-bootstrap/Container";
import Card from "react-bootstrap/Card";
import Accordion from "react-bootstrap/Accordion";
import Button from "react-bootstrap/Button";
import { hexToInt } from "../utilities/HexToInt";
import { showAddress } from "../utilities/ShowAddress";
export function GalleryList({ header, filter }) {
  const { theme } = useTheme();
  const { spawnData } = useSpawn();
  return (
    <Container animation="border" role="status">
      <Card className={theme ? "bg-dark text-light" : "bg-light"}>
        {header ? (
          <CardHeader cardHeader={"All Wam0s"} eraseButton={"wamos"} />
        ) : null}
        <Card.Body>
          {!spawnData ? (
            <Loading />
          ) : (
            spawnData.wamoOwnerData.map((wamo, i) =>
              !filter.includes(wamo[1]) ? (
                <Accordion key={i} defaultActiveKey={hexToInt(wamo[0])}>
                  <Accordion.Item eventKey={hexToInt(wamo[0])}></Accordion.Item>
                  <Accordion.Header>Wamo: {hexToInt(wamo[0])}</Accordion.Header>
                  <Accordion.Body>Owner: {showAddress(wamo[1])}</Accordion.Body>
                </Accordion>
              ) : null
            )
          )}
        </Card.Body>
      </Card>
    </Container>
  );
}
