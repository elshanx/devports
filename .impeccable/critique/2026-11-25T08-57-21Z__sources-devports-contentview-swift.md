---
target: popover
total_score: 32
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:e88360605a78cd41f5f13cbcb35b928166105195339f4ed485508f984bd4cc24"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T08-57-21Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 4 | Stop, Stop all and restart each show their state. The list refreshes itself. |
| 2 | Match System / Real World | 3 | Port chips on postgres and ControlCenter open a browser, but these ports do not serve web pages |
| 3 | User Control and Freedom | 3 | Dev stops can restart. Docker and other stops cannot. |
| 4 | Consistency and Standards | 4 | One footer style, one term for each thing |
| 5 | Error Prevention | 3 | Stop all confirms, protected rows show a lock with a reason |
| 6 | Recognition Rather Than Recall | 3 | The "…" menu has text labels and a keyboard list |
| 7 | Flexibility and Efficiency | 3 | Full keyboard control. No global hotkey, no filter. |
| 8 | Aesthetic and Minimalist Design | 3 | The dev view is clean. In the "all" view, processes with only random ports fill most rows. |
| 9 | Error Recovery | 3 | Errors say what failed and why. A failed stop has no retry next to the message. |
| 10 | Help and Documentation | 3 | Keyboard list in the menu, tooltips on every control |
| **Total** | | **32/40** | **Good** |

## Design Specificity Verdict
A calm native utility. The dev card is the hero, and "Other" rows are compact, so the hierarchy matches the task. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P3] Random-port processes fill the "all" view. Five "claude" rows and rapportd each have one port above 49152. Fix: put processes with only random ports into one collapsed line, for example "6 apps on random ports". Command: $impeccable distill
- [P3] Port chips open non-web ports in the browser. postgres :5432 and ControlCenter :5000 open a blank or error page. Fix: in "Other" rows, a click copies the port number instead, or the chip is plain text. Command: $impeccable clarify

## Persona Red Flags
Alex (power user): no global hotkey; no type-to-filter.
Sam (VoiceOver and keyboard): no new issues. Labels, selection and lock reasons are spoken.

## Minor Observations
- The dev card and the compact rows have different heights. This is correct hierarchy.

## Questions to Consider
- Should "Show all ports" hide random ports by default, the same as the dev view hides debugger ports?
