export function storageParse(value) {
  return ["true", "false"].includes(value) ? JSON.parse(value) : value;
}
