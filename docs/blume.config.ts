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

  // GitHub Pages project site: served from a subpath, so `base` must match the
  // repo name and `site` must be set — Pages exposes no origin to detect.
  deployment: {
    output: "static",
    site: "https://aaronabuusama.github.io",
    base: "/dag-plugin",
  },
});
