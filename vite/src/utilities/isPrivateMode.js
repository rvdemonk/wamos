const fs = require("fs");

export function isPrivateMode() {
  const raw = fs.readFileSync("../artifacts/world.settings.json");
  const settings = JSON.parse(raw);
  return settings.privateMode;
}
