# Display and startup contracts

## Scope and evidence
Recovered from the archived July 7 physical-font session in the authorized
Codex archived_sessions directory. The source horizon was surveyed through its
conflict-resolution handoff. This independent source history is not formal
project-current memory. No exact original project commit is established.
Validation below is reported by the source, not rerun now. No raw log is copied.

## Adopted display policy
Prefer monitor physical dimensions for a nominal 4 mm font target, falling back
to pixel-resolution scaling. Avoid monitor-name special cases and unnecessary
global state; keep the calculation local. The geometry calculation is a font
size heuristic, not proof that rendered glyphs physically measure 4 mm.

A GUI investigation found monitor mm-size returned a list such as (310 200),
where an earlier implementation assumed a dotted pair. That mismatch silently
selected fallback sizing. Supporting both shapes corrected the calculation.
The fallback uses the smaller width/height ratio against 1920 by 1080 at
face height 110; 3072 by 1920 therefore yields 176.

## Verification and unresolved scope
The source reports isolated GUI results 114 for physical sizing, 110 at base
resolution and 176 for scaled fallback, plus a parenthesis check. A later
conflict resolution combined physical-first behavior with that fallback.
The agent edited the conflict but did not continue the rebase; the owner staged
the result. This is not fresh end-to-end startup acceptance.

## Next action
Recover the module/loading contract discussion separately, preserving the
distinction between source experiments and the names adopted on main.
