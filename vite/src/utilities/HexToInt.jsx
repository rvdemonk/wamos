export function hexToInt(value) {
  return value["_isBigNumber"] ? parseInt(value["_hex"], 16) : value;
}
