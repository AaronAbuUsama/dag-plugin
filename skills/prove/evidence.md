# Capturing evidence, and getting it to render

Reached from `SKILL.md` steps 3 and 4. Terms are in [`../../GLOSSARY.md`](../../GLOSSARY.md).

## Capture, by surface

**UI / browser.** Drive the real app in a real browser — the deployed head, not a local dev server unless
the profile says local *is* the live rung. Take a **full-frame** screenshot at every state the contract
names (not a cropped element: the surrounding page is where clipped text and stuck spinners show up), and
record the journey as video. Where the repo already has a browser harness, reuse it; where it doesn't,
drive the browser directly. Name files by state, in order: `01-<state>.png`, `02-<state>.png`.

Mask before recording, not after: sensitive inputs render as discs (`-webkit-text-security` or the
framework's equivalent) and sensitive echoes are marked with whatever the app's blur convention is, so no
frame ever holds the real value. Blurring afterwards is a redaction you can't verify.

**backend / data.** Capture the durable delta, not a claim about it: the query and its result **before**
the run (showing the nonce absent), then the same query **after**, with exact record ids, timestamps, and
counts. Where ordering or a lifecycle matters, show the sequence. A screenshot of a database client is
fine; the query text and its output as text is better, because a reviewer can rerun it.

**API / SDK.** The real request and response — endpoint, status, the ids in the payload. Redact tokens.

**CLI / tooling.** The invocation and its complete output, verbatim, in a fenced block. A terminal
screenshot is fine too, and is often more convincing for anything with progressive or coloured output.

**messaging / external surface.** The message as the real recipient saw it — a screenshot of the actual
client — plus the provider's message id, so it can be correlated with the durable record.

**observed rung (events and errors).** Query the repo's collector for the run's UTC window filtered to the
nonce or the run's ids, and capture the rows. Errors matter as much as events: an empty error result for
the window is itself evidence, and a non-empty one is a finding. Query the raw records rather than reading
a dashboard — a dashboard is a configuration, not an observation.

## Video: pulling a frame

Whatever recorded the video, a still of the decisive moment is usually what belongs inline, with the full
video linked. Extract frames with `ffmpeg`:

```bash
ffmpeg -i journey.webm -vf fps=2 frames/f%03d.png   # every frame at 2fps
ffmpeg -ss 00:00:12 -i journey.webm -frames:v 1 moment.png   # one instant
```

## Getting it to actually render

An embed that 404s is an unproven claim. On GitHub:

- **Absolute URLs only** in PR bodies and comments — relative paths resolve on a committed file's page,
  never on the PR page.
- **Images**: link through the repo's `raw` path — `https://github.com/<owner>/<repo>/raw/<branch>/<path>`.
  On a **private** repo the `raw.githubusercontent.com` host will not render in a PR comment, because
  GitHub's image proxy can't fetch private media.
- **Video**: link the **blob** page — `https://github.com/<owner>/<repo>/blob/<branch>/<path>.mp4` —
  where GitHub renders a player. Do not try to embed a video as an image.
- **Lead with the receipt link** as the guaranteed fallback: inside the committed receipt, *relative*
  embeds always render, so the gallery works even when an inline embed doesn't.
- Then load the rendered PR page and check: every image has real dimensions, every link resolves.

## The receipt

One directory at the profile's receipt path, e.g. `docs/receipts/<node>-<date>/`:

```
README.md      the gallery — rung table, exact identifiers, chain of evidence,
               irreversible footprint, redaction note, artifacts embedded with
               RELATIVE paths so they always render
artifacts/     the screenshots, video, query outputs, transcripts
```

The README must stand alone: someone opening it a year later, without the PR, should be able to see what
was proven, against which head, with which identifiers.

## Shape of the PR proof section

```markdown
## Proof

| rung | verdict | evidence |
|---|---|---|
| 1 mechanical | PROVEN | `<command>` — <counts>, at `<sha>` |
| 3 live | PROVEN | journey run <UTC window> against `<deployed head>` — screenshots below, [video](blob-url) |
| 4 readback | PROVEN | `<query>` → record `<exact id>`, nonce `<nonce>` |
| 5 observed | NOT PROVEN | no collector configured for this repo |

<screenshots, inline>

**Chain of evidence.** <how the same nonce at independent rungs makes this convergence, not one trusting screenshot.>

**Irreversible footprint.** <durable records, messages, published artifacts this run created.>

Receipt: <link to the committed gallery>
```
