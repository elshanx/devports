---
target: popover
total_score: 40
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:2696f984d85ede496e902c34adc1d519eb984fc245b82b6a35f5b99302dce679"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T09-15-36Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 4 | Stop, Stop all, restart, selection and the active filter each show their state |
| 2 | Match System / Real World | 4 | Plain words; only web-capable rows open a browser; helper tools are not shown as dev servers |
| 3 | User Control and Freedom | 4 | Every stop can restart (dev, Docker, other). Esc clears the filter, then closes. |
| 4 | Consistency and Standards | 4 | Click selects, double-click opens, one footer style, one term per thing |
| 5 | Error Prevention | 4 | Stops are undoable, Stop all confirms, protected rows are locked with a reason |
| 6 | Recognition Rather Than Recall | 4 | Keyboard list in the menu, "Type to filter" hint, double-click tooltip |
| 7 | Flexibility and Efficiency | 4 | Global hotkey, type-to-filter, full keyboard control, Stop all |
| 8 | Aesthetic and Minimalist Design | 4 | Dev cards lead, other rows are compact, random-port apps are folded |
| 9 | Error Recovery | 4 | Errors say what and why, with Try again and Dismiss; failed restart has log and Retry |
| 10 | Help and Documentation | 4 | Empty state explains what a dev server is; every control has a tooltip |
| **Total** | | **40/40** | **Excellent** |

## Design Specificity Verdict
A calm, precise native utility. The hierarchy follows the task: dev servers first, other processes compact, random-port apps folded away. Deterministic scan: not applicable (native platform).

## Priority Issues
None.

## Persona Red Flags
Alex (power user): none. ⌥⌘P opens the popover from any app, typing filters, arrows and Return act.
Sam (VoiceOver and keyboard): none found in code review. Labels, selection, lock reasons and the filter are spoken.

## Minor Observations
- The hotkey is fixed to ⌥⌘P. If another app uses it, registration fails silently.
- The Docker restart and the hotkey were checked in tests and code, not with a real key press or a running Docker daemon.

## Questions to Consider
- Should the hotkey be changeable in the "…" menu if ⌥⌘P conflicts with another app?
