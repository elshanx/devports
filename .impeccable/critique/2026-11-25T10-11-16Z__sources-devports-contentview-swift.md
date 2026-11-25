---
target: popover
total_score: 40
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:ff4e0db54fbabbd043982ef557204cce64e2cc981abf1a002e1d6765eceff3e1"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T10-11-16Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 4 | Stop, Stop all, restart, selection, filter and copy each show their state |
| 2 | Match System / Real World | 4 | Plain words; errors name the real cause ("needs administrator rights") |
| 3 | User Control and Freedom | 4 | Every stop can restart; Esc clears the filter, then closes and gives focus back |
| 4 | Consistency and Standards | 4 | Click selects, double-click opens, one footer style |
| 5 | Error Prevention | 4 | Stops are undoable, Stop all confirms, protected rows are locked |
| 6 | Recognition Rather Than Recall | 4 | Keyboard list, "Type to filter" hint, tooltips |
| 7 | Flexibility and Efficiency | 4 | Global hotkey, filter, keyboard control, Stop all |
| 8 | Aesthetic and Minimalist Design | 4 | Clear hierarchy, compact other rows, folded random-port apps |
| 9 | Error Recovery | 4 | Each error offers only an action that can work: Copy command, Open Settings, Retry with log |
| 10 | Help and Documentation | 4 | Empty state explains dev servers; tooltips on every control |
| **Total** | | **40/40** | **Excellent** |

## Design Specificity Verdict
A calm, precise native utility. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P3] Restart has no key. ⌘⌫ stops the selected row, but the way back (Restart in "Recently stopped") needs the mouse, or macOS keyboard navigation turned on. Fix: ⌘Z restarts the most recently stopped server, and the Keyboard list shows it. Command: $impeccable harden
- [P3] The double-click tooltip shows on every hover over a card. It helps once and is noise after. Fix: put the hint on the port chip tooltip ("Open http://localhost:4321, or double-click the card") and remove the card tooltip. Command: $impeccable quieter

## Persona Red Flags
Alex (power user): ⌘⌫ has no keyboard undo.
Sam (keyboard only): same; restart needs Tab navigation to be on in System Settings.

## Minor Observations
- "Copy command" copies `sudo kill <pid>`, which stops the main process only, not its child processes.

## Questions to Consider
- Should ⌘Z also undo "Stop all" by restarting every server it stopped?
