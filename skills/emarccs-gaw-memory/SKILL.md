---
name: emarccs-gaw-memory
description: Navigate and interpret Emarccs GAW memory when resuming work, examining architectural history, or maintaining project knowledge.
---

# Emarccs GAW Memory

Use the git-agent-workflow skill and public GAW CLI to discover the selected
formal worktree and its declared workspace. Do not assume their names or
locations. Check validity before memory writes. Use the public GAW CLI for live
branch, worktree and lifecycle state rather than historical completion notes.

The paths below are relative to the discovered formal GAW worktree. They
identify workspace data, not resources bundled with this skill.

## Reading order

- Read `memory/current.md` when present for the represented state, active
  objective, validation limits, unresolved questions, and next action.
- Read `memory/architecture.md` when present for project responsibilities,
  integration boundaries, capabilities, and consequential design reasons.
- Read `memory/backlog.md` when present for deferred work, its motivation and
  evidence limits. Use current memory and active authorization to choose what
  to resume; backlog entries do not grant permission to execute them.
- Read `memory/reconstruction.md` when interpreting recovered historical
  claims, source limitations, corrections, or attributed validation.

If these files are absent, substantive project memory has not yet been
established. This navigation skill alone makes no implementation claims.

## Historical interpretation

Interpret each checkpoint within its stated scope. Do not project later names,
decisions, or capabilities into earlier states.

Distinguish original discussion and validation from retrospective explanation
and later repository inspection. Memory is a useful prior, not fresh proof of
runtime behavior.

GAW commit parents encode the historical dependencies necessary to interpret
the knowledge state represented by the commit. For non-root checkpoints, the
first parent supplies inherited knowledge history; initialization roots have no
first parent. Additional parents supply other necessary context through exact
commits without merging their trees. Parent edges are not citations,
knowledge-adoption records, approval markers or validation results.

Recover relevant evolution through formal first-parent history. Inspect actual
parents and committed trees when historical context matters. Auxiliary content is
located beneath the UUID root found in its tree. Additional-parent positions do
not have fixed business roles.

Formal GAW remains project-current-memory authority. Git reachability describes
which commits remain retained. Recover ancestry and parent relationships from
Git rather than maintaining a parallel checkpoint or source registry. Preserve
useful historical explanations without requiring a separate explanation for
every existing parent.

When selecting additional parents, follow git-agent-workflow's association rules
without adding a separate necessity test. Reading a source, integrating knowledge
or preserving evidence does not by itself require a parent.

Ordinary reading and memory consolidation do not trigger archival assessment.
Use the archive workflow only for an explicit preservation request or a concrete
independent need to preserve original evidence. The project's temporary INBOX
notes are research inputs, not archive tasks; distill useful conclusions into
memory without copying the notes.

Maintain this entry point when memory organization or interpretation changes,
not after every memory update. It grants no project-write, test, network,
lifecycle, or external-action authorization.
