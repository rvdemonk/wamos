import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  // chatGPT code vvvv
  transformers: {
    "**/*.json": ["json-loader"],
  },
});
