---
target: popover
total_score: 25
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:23cdb41d9de2e7a61cca7c41ea46e824f424658b8dc8d571619277d596373f11"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T08-30-50Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 3 | Stop shows a spinner; Restart gives no "starting" state or success feedback |
| 2 | Match System / Real World | 3 | "internal" ports and the sunrise icon for Open at login need a tooltip to decode |
| 3 | User Control and Freedom | 3 | Restart covers dev stops; Docker stops have no undo; card click can open the browser by accident |
| 4 | Consistency and Standards | 3 | Icon buttons are consistent; one card has four different click results |
| 5 | Error Prevention | 3 | Stop all needs a second click; protected processes have no stop button |
| 6 | Recognition Rather Than Recall | 2 | Footer is icon-only; card click and internal ports are hidden behind tooltips |
| 7 | Flexibility and Efficiency | 1 | No keyboard shortcuts (Cmd-R, Cmd-Q, Esc, arrow keys), no global hotkey, no search |
| 8 | Aesthetic and Minimalist Design | 3 | Clean, but each row has 4 text lines and the red Stop all block is the loudest element |
| 9 | Error Recovery | 2 | Errors are one red line in the footer; restart failures only show in a log file |
| 10 | Help and Documentation | 2 | Tooltips only |
| **Total** | | **25/40** | **Acceptable** |

## Design Specificity Verdict
Port chips coloured by kind, the "+N internal" note and the Recently stopped list are specific to this product. The card list, tinted icon buttons and section titles are standard SwiftUI patterns that any menu bar utility could use. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P1] Row card has four click results (card opens browser, folder opens Finder, chips open browser, stop kills). The card click is invisible. Fix: remove the card click or make the project name an explicit "open" link with an arrow icon; keep one action per target. Command: $impeccable clarify
- [P1] No keyboard path. Icon-only plain buttons, no shortcuts, no Esc, no arrow navigation, symbol names as accessibility labels. Fix: add .accessibilityLabel to every icon button, Cmd-R refresh, Cmd-Q quit, Esc close, arrow keys move between rows, Return opens, Delete stops. Command: $impeccable harden
- [P2] Restart and stop give weak feedback. After Restart the item vanishes and the row returns up to 3 s later; failures only appear in the log. Fix: keep the item in a "Starting…" state until its port listens, then show a short "Running on :4321" confirmation; on timeout show "Did not start, open log". Command: $impeccable harden
- [P2] Row hierarchy is flat. Name, folder, command and ports are 4 lines; the command line is mostly a truncated path. Fix: merge folder into the subtitle, move the command to a tooltip, keep name + ports as the scan line. Command: $impeccable distill
- [P2] Stop all is the loudest element and sits inside the scroll area. With many rows it scrolls away, and its red fill competes with the content. Fix: move it to the header or footer as a quiet red-text button that turns solid only on confirm. Command: $impeccable quieter

## Persona Red Flags
- Alex (power user): no shortcut to open DevPorts, no Cmd-R, no Esc, no type-to-filter, no keyboard way to stop the selected server.
- Sam (VoiceOver, keyboard): icon buttons read as "stop.fill", "doc.text", "sunrise"; the card click has no keyboard equivalent; state is shown by colour only (purple vs grey sunrise, green vs grey tiles).
- Riley (stress tester): 20 dev servers push Stop all out of view; a restart of a daemonising tool (astro dev) shows success while the log is almost empty; a long project name has lineLimit(1) with no tooltip.

## Minor Observations
- "+5 internal" is tertiary text on vibrancy; contrast is low.
- Light mode was not checked; green text on 12% green may fail contrast.
- "Show all ports" changes its label but does not show the current state; a two-segment Dev | All control would.
- The header has space for the last refresh time or a live indicator.
- The menu bar count counts only dev servers, which is good, but there is no tooltip that says so.

## Questions to Consider
- Should the popover be keyboard-first, like Spotlight, with type-to-filter?
- Does Stop all need to be visible at all times, or only when 2 or more dev servers run?
- What would a running server look like if uptime and the last request were visible?
