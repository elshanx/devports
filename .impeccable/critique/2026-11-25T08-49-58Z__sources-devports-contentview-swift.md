---
target: popover
total_score: 31
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:d3b2ed40ecf67a05e5c4e3dfe7f4315872fcc777ea571db39c2a02bceb0d45d3"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T08-49-58Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 3 | Restart states are clear. Refresh changes the list with no visible feedback. |
| 2 | Match System / Real World | 3 | "+5 internal" still needs a tooltip |
| 3 | User Control and Freedom | 3 | Dev stops can restart. Docker and other stops cannot. |
| 4 | Consistency and Standards | 3 | Refresh is a green filled circle, "…" is a bare glyph, side by side |
| 5 | Error Prevention | 3 | Stop all confirms, protected rows show a lock |
| 6 | Recognition Rather Than Recall | 3 | The "…" menu has text labels and a keyboard list |
| 7 | Flexibility and Efficiency | 3 | Full keyboard control. No global hotkey, no filter. |
| 8 | Aesthetic and Minimalist Design | 3 | The dev view is clean. The "all" view has duplicate "claude" rows and long Application Support paths. |
| 9 | Error Recovery | 3 | Failed restart has reason, log and retry |
| 10 | Help and Documentation | 3 | Keyboard list in the menu, tooltips on every icon |
| **Total** | | **31/40** | **Good** |

## Design Specificity Verdict
A focused native utility. Kind tints and port chips carry the identity. The dev view is calm and fits the Operate mode. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P3] Refresh and "…" do not match. Refresh is the only filled tinted icon, and the list already refreshes every 3 seconds. Fix: make Refresh quiet like "…", or remove it and keep ⌘R. Command: $impeccable distill
- [P3] The "all" view repeats rows. Two "claude" rows show, each with a long ~/Library/Application Support path. Fix: show only the last folder name for paths outside ~/dev, or merge rows with the same name. Command: $impeccable polish
- [P3] "+5 internal" is jargon. Fix: "+5 hidden" or "+5 other ports", with the tooltip kept. Command: $impeccable clarify

## Persona Red Flags
Alex (power user): no global hotkey; no type-to-filter in the "all" view.
Sam (VoiceOver and keyboard): the lock icon in dark mode is very faint, but it has a spoken label. Selection and buttons have labels.

## Minor Observations
- The lock icon uses tertiary colour. In dark mode it is close to invisible.
- The kind tile shows only on dev and Docker rows. This is correct now.

## Questions to Consider
- With auto-refresh every 3 seconds, does the popover need a visible Refresh button?
