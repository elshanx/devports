---
target: popover
total_score: 39
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:d26f847fc3c92806bd62ddcf45511d6087af06947c59d6ebc2015408982967e0"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T20-22-06Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | spinners, Starting, Running on :3000, summary |
| 2 | Match System / Real World | 4 | clear terms |
| 3 | User Control and Freedom | 4 | restart as undo by button or Cmd-Z, Esc |
| 4 | Consistency and Standards | 4 | one icon-button style |
| 5 | Error Prevention | 4 | Stop all confirm, lock, repeat guards |
| 6 | Recognition Rather Than Recall | 4 | filter hint in header, keys in More menu |
| 7 | Flexibility and Efficiency | 4 | keys for every main action |
| 8 | Aesthetic and Minimalist Design | 4 | red only for errors and hover |
| 9 | Error Recovery | 3 | failed restart reason cut to one line |
| 10 | Help and Documentation | 4 | keys listed, empty state explains |
| **Total** | | **39/40** | **Excellent** |

## Priority Issues
- [P3] Failed restart reason truncated. Fix: lineLimit(2) on failed rows. Command: harden
- [P3] Restart button does not show Cmd-Z. Fix: add (⌘Z) to the tooltip of the row Cmd-Z acts on. Command: clarify

## Persona Red Flags
- Jordan: cut reason on failed restart.

## Minor Observations
- Green tile and green chip repeat one signal.
- Cmd-Z works only while the popover is open (app menu).
