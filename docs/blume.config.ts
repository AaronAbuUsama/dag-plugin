import { defineConfig } from "blume";

export default defineConfig({
  title: "DAG Engineering",
  description:
    "Turn intent into a graph of provable work and walk it — grill, chart, pre-flight, execute, prove.",

  navigation: {
    tabs: [
      { label: "Docs", path: "/" },
      { label: "Changelog", path: "/changelog" },
    ],
  },

  content: {
    // Changelog entries are files under docs/changelog/, not GitHub Releases:
    // this repo cuts no releases, and the releases source needs a token on a
    // private repo.
    sources: [{ type: "filesystem", root: "docs" }],
  },

  theme: {
    accent: "teal",
    mode: "system",
  },

  // A GitHub Pages *project* site is served from /<repo>, so the CI build sets
  // BASE_PATH. Local dev sets nothing and serves from the root — the base is a
  // deploy detail and should never make `dev` land on a blank page.
  deployment: {
    output: "static",
    site: "https://aaronabuusama.github.io",
    ...(process.env.BASE_PATH ? { base: process.env.BASE_PATH } : {}),
  },
});
