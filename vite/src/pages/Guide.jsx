import React from "react";
import Accordion from "react-bootstrap/Accordion";
import guide from "../data/guide.json";

export function Guide() {
  return (
    <div className="container">
      <div className="py-4 vh-100">
        <h1 className="display-5 fw-bold py-4 text-center">Guide</h1>
        {guide.map((item) => (
          <Accordion defaultActiveKey={item.id}>
            <Accordion.Item eventKey={item.id}></Accordion.Item>
            <Accordion.Header variant="success">{item.header}</Accordion.Header>
            <Accordion.Body>{item.body}</Accordion.Body>
          </Accordion>
        ))}
      </div>
    </div>
  );
}
