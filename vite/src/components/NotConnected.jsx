import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Card";

import { useTheme } from "../context/ThemeContext";
import { useEth } from "../context/EthContext";
export function NotConnected() {
  const { theme } = useTheme();
  const { connectWallet } = useEth();
  return (
    <>
      <Card.Body>
        <Card.Title>You are not connected</Card.Title>
        <Card.Text>Wam0s exist on the chain.</Card.Text>
        <Button
          onClick={() => connectWallet()}
          variant={theme ? "outline-light" : "outline-dark"}
        >
          Connect
        </Button>
      </Card.Body>
    </>
  );
}
