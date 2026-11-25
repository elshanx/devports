---
target: popover
total_score: 34
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:1f36c0e8d77e5c9c35f08f859894657f35d97494cfec62e799cd1dfa562c430a"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T09-06-10Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 4 | Stop, Stop all, restart and selection each show their state |
| 2 | Match System / Real World | 4 | Only web-capable rows open a browser; "hidden" and "random ports" read plainly |
| 3 | User Control and Freedom | 3 | Dev stops can restart. Docker and other stops cannot. |
| 4 | Consistency and Standards | 4 | Click selects, double-click opens, like a Finder list |
| 5 | Error Prevention | 3 | Stop all confirms, protected rows show a lock with a reason |
| 6 | Recognition Rather Than Recall | 3 | Double-click to open is not shown anywhere |
| 7 | Flexibility and Efficiency | 3 | Full keyboard control. No global hotkey, no filter. |
| 8 | Aesthetic and Minimalist Design | 4 | The "all" view now shows 3 Other rows and one toggle line |
| 9 | Error Recovery | 3 | Errors say what and why. A failed stop has no retry next to the message. |
| 10 | Help and Documentation | 3 | Keyboard list in the menu, tooltips on every control |
| **Total** | | **34/40** | **Good** |

## Design Specificity Verdict
A calm native utility with clear hierarchy: the dev card leads, other processes are compact, random-port apps are folded away. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P3] Single click waits for a possible double-click. SwiftUI delays the single-tap action by the double-click interval, so the highlight appears about 0.3 s late. Fix: select on mouse down with a simultaneous gesture, and keep double-click to open. Command: $impeccable polish
- [P3] Double-click to open is hidden. Nothing in the card or the Keyboard list says it. Fix: add "Double-click  Open in browser" to the Keyboard list, and a card tooltip. Command: $impeccable clarify
- [P3] "Hide N apps on random ports" moves to the bottom of a long list. After you expand the group, you must scroll to collapse it. Fix: keep the toggle line above the expanded rows. Command: $impeccable layout

## Persona Red Flags
Alex (power user): no global hotkey; no type-to-filter.
Sam (VoiceOver and keyboard): selection is spoken. Double-click has a keyboard equivalent (Return).

## Minor Observations
- The header count does not change in the "all" view. This is correct, the menu bar shows the same number.

## Questions to Consider
- Is a global hotkey (for example ⌥⌘P) worth one more setting?
