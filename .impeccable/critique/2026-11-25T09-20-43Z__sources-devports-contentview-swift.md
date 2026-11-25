---
target: popover
total_score: 38
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 0
target_identity: "file:/Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift"
target_fingerprint: "sha256:2696f984d85ede496e902c34adc1d519eb984fc245b82b6a35f5b99302dce679"
target_path: /Users/elshanx/dev/pet-projects/devports/Sources/DevPorts/ContentView.swift
timestamp: 2026-11-25T09-20-43Z
slug: sources-devports-contentview-swift
---
Method: design review only (detector not applicable, native platform)

## Design Health Score
| # | Heuristic | Score | Key Issue |
|---|---|---|---|
| 1 | Visibility of System Status | 4 | Stop, Stop all, restart, selection and the filter each show their state |
| 2 | Match System / Real World | 4 | Plain words; helper tools are not shown as dev servers |
| 3 | User Control and Freedom | 3 | After Esc closes the popover, focus does not go back to the app you used before |
| 4 | Consistency and Standards | 4 | Click selects, double-click opens, one footer style |
| 5 | Error Prevention | 4 | Stops are undoable, Stop all confirms, protected rows are locked |
| 6 | Recognition Rather Than Recall | 4 | Keyboard list, "Type to filter" hint, double-click tooltip |
| 7 | Flexibility and Efficiency | 4 | Global hotkey, filter, full keyboard control |
| 8 | Aesthetic and Minimalist Design | 4 | Clear hierarchy, folded random-port apps |
| 9 | Error Recovery | 3 | "Try again" shows for a permission error, where a retry cannot succeed |
| 10 | Help and Documentation | 4 | Empty state explains dev servers; tooltips on every control |
| **Total** | | **38/40** | **Excellent** |

## Design Specificity Verdict
A calm, precise native utility. Deterministic scan: not applicable (native platform).

## Priority Issues
- [P2] Focus is lost after the popover closes. togglePopover now calls NSApp.activate(). When Esc closes the popover, DevPorts stays the active app with no window, so your next key presses go nowhere until you click another app. This hits the ⌥⌘P → Esc flow every time. Fix: hide DevPorts when the popover closes (NSPopoverDelegate popoverDidClose → NSApp.hide(nil)), which gives focus back to the previous app. Command: $impeccable harden
- [P3] "Try again" promises a recovery that cannot work. For "You do not have permission" and "docker command is not installed", a second try fails the same way. Fix: for a permission error, offer "Copy command" that copies `sudo kill <pid>`; for a missing docker command, show only Dismiss. Command: $impeccable clarify

## Persona Red Flags
Alex (power user): ⌥⌘P → Esc leaves the keyboard dead until a click. This breaks the fastest flow.
Sam (keyboard only): same issue; there is no keyboard way back to the previous app except ⌘Tab.

## Minor Observations
- The double-click tooltip shows on every hover over a card. It is useful once and noisy later.
- The last run scored 40/40. A fresh review of the hotkey and error paths found the two issues above, so that score was too high.

## Questions to Consider
- Should the double-click tooltip show only on the name, not on the whole card?
