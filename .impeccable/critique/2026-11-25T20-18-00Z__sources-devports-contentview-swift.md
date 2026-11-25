---
target: popover
total_score: 38
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:d4c155d6db1c233c3e223687c30903effe598e542f81d844c823d40c978d999d"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T20-18-00Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 4 | spinners, Starting, Running on :3000, summary line |
| 2 | Match System / Real World | 4 | clear terms, "+2 hidden" explained by tooltip |
| 3 | User Control and Freedom | 4 | restart as undo, Esc, dismiss on banners |
| 4 | Consistency and Standards | 3 | two icon-button styles: stop has no background, forget x has gray circle |
| 5 | Error Prevention | 4 | Stop all confirm, lock on protected, repeat stop ignored |
| 6 | Recognition Rather Than Recall | 3 | gray stop square reads as checkbox at rest; no filter hint in dev view |
| 7 | Flexibility and Efficiency | 4 | full keyboard set and global hotkey |
| 8 | Aesthetic and Minimalist Design | 4 | red only for errors and hover |
| 9 | Error Recovery | 4 | reason, Open log, Retry, Copy command |
| 10 | Help and Documentation | 4 | keys in More menu, empty state explains dev servers |
| **Total** | | **38/40** | **Excellent** |

## Priority Issues
- [P2] Stop control does not look like a button at rest (row gray square, footer Stop all looks disabled). Fix: neutral circle background like the forget x; Stop all in primary 0.7. Command: polish
- [P2] Two icon-button styles (stop vs forget x). Fix: one neutral-circle style. Command: polish
- [P3] No filter hint in dev view. Fix: "2 dev servers · Type to filter". Command: clarify
- [P3] Double-click tooltip on every row (carried). Fix: only on selected row or remove. Command: distill
- [P3] No keyboard restart (carried). Fix: Cmd-Z restarts latest stopped. Command: harden

## Persona Red Flags
- Alex: no Cmd-Z after a wrong Cmd-Delete.
- Jordan: gray square not read as stop; gray Stop all reads disabled.
- Sam: labels good; no visual-only issue.

## Minor Observations
- Green tile plus green chip repeat the same signal.
- Failed reason truncated to one line; tooltip only.
