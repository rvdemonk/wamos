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
export function GalleryList({ lobby, filter }) {
  const { theme } = useTheme();
  const { spawnData } = useSpawn();
  return (
    <Container animation="border" role="status">
      <div className="py-4 vh-100 text-center">
        <Card className={theme ? "bg-dark text-light" : "bg-light"}>
          <CardHeader cardHeader={"All Wam0s"} eraseButton={"wamos"} />
          <Card.Body>
            {!spawnData ? (
              <Loading />
            ) : (
              spawnData.wamoOwnerData.map((wamo) => (
                <Accordion defaultActiveKey={hexToInt(wamo[0])}>
                  <Accordion.Item eventKey={hexToInt(wamo[0])}></Accordion.Item>
                  <Accordion.Header>Wamo: {hexToInt(wamo[0])}</Accordion.Header>
                  <Accordion.Body>
                    <>
                      <div>Owner: {showAddress(wamo[1])}</div>
                    </>
                    {lobby ? <Button>hello</Button> : null}
                  </Accordion.Body>
                </Accordion>
              ))
            )}
            ;
          </Card.Body>
        </Card>
      </div>
    </Container>
  );
}
