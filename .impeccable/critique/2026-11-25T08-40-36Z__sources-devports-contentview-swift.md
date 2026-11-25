---
target: popover
total_score: 28
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:cc50a1334dcef6455438fd7f883966c872a9258d77ade9a042b9d5fae0872d8c"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T08-40-36Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 3 | Restart now shows starting, running and failed. Refresh gives no visible feedback. |
| 2 | Match System / Real World | 3 | "+5 internal", the sunrise icon, and folders "/" or "~" need decoding |
| 3 | User Control and Freedom | 3 | Restart, Esc and the Stop all confirm work. Docker and other stops have no undo. |
| 4 | Consistency and Standards | 3 | Some "Other" rows have a stop button and some do not, with no reason shown |
| 5 | Error Prevention | 3 | Stop all needs two clicks. A single stop has no confirm, but restart covers it. |
| 6 | Recognition Rather Than Recall | 2 | Four footer buttons are icon-only. Keyboard shortcuts are only in tooltips. |
| 7 | Flexibility and Efficiency | 3 | Arrows, Return, Cmd-Delete, Esc, Cmd-R, Cmd-Q. No global hotkey, no filter in "all" view. |
| 8 | Aesthetic and Minimalist Design | 3 | The header uses about 60 pt to repeat the menu bar count. The "all" view repeats grey gear tiles. |
| 9 | Error Recovery | 3 | Failed restart gives a reason, Open log and Retry. A stop error is still one red line. |
| 10 | Help and Documentation | 2 | Tooltips only |
| **Total** | | **28/40** | **Good** |

## Design Specificity Verdict
LLM assessment: a clean native macOS utility. The kind tints (green dev, blue Docker, grey other) and the port chips carry the identity. Layout is a generic card list. For an Operate surface this is correct. The missed opportunity: the port is the thing the user clicks most, but the project name has the most weight.
Deterministic scan: not applicable (native platform).

## Priority Issues
- [P2] Footer emphasis is inverted. "Show all ports" is a filled accent pill and is the loudest control, but it is a view filter. Four icon-only buttons sit next to it. Fix: make the toggle quiet, keep Refresh visible, and move logs, open at login and quit into one "..." menu with text labels. Command: $impeccable distill
- [P2] The "all ports" view is noisy. ControlCenter shows folder "/", caveman-proxy shows "~", claude shows a random port :57657, every row has the same grey gear tile, and grey chips on grey cards have low contrast. Fix: hide folders that are "/" or "~", hide the tile for "Other", raise chip contrast. Command: $impeccable polish
- [P2] Stop availability is unexplained. caveman-proxy has a stop button, postgres does not. The user cannot tell if this is a bug. Fix: show a lock symbol with the tooltip "System process. DevPorts does not stop it." Command: $impeccable clarify
- [P2] The header repeats the menu bar. "DevPorts" plus "1 dev server running" uses two lines and wide padding. Fix: one compact line, or put the count in the footer. Command: $impeccable layout
- [P3] Shortcuts are hidden. Only tooltips mention Cmd-Delete. Fix: put shortcut hints in the new "..." menu as menu key equivalents. Command: $impeccable clarify

## Persona Red Flags
Alex (power user): No global hotkey opens the popover. The "all" view has 10+ rows and no type-to-filter. Return opens only the first port.
Sam (VoiceOver and keyboard): Selected rows announce isSelected, and buttons have labels. Grey port chips on the grey card are near 3:1 contrast. The stop button is missing on protected rows with no spoken reason.

## Minor Observations
- The stop button aligns to the top of a tall card and looks like it floats.
- The login item shows grey "off" with the same weight as active buttons.
- The last card is cut at 460 pt. This is a good scroll hint. Keep it.

## Questions to Consider
- What if the port chip were the row's main element, and the name were secondary?
- Does the "all" view need cards at all, or would one compact line per process work better?
