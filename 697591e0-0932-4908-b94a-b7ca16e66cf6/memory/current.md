# Display and startup contracts

## Scope and evidence
This source joins the July 7 physical-font work and July 10 structural/testing
discussion, both originally started in this project. Entire horizons were
surveyed for durable decisions. The final structural-session startup-source
request was interrupted; no completion is attributed to that session.
The long packaging source contains separate completed startup investigation.
No exact original project commit is established; no runtime check is rerun.

## Display contract
Physical-first nominal 4 mm sizing accepts list and dotted-pair mm-size values,
then falls back to the smaller pixel ratio against 1920 by 1080 at height 110.
Avoid per-monitor names and unnecessary global configuration. Source GUI
checks reported physical height 114 and fallback heights 110/176; those values
are face parameters, not measured glyph dimensions. Conflict edits did not
constitute an agent-completed rebase.

## Module and initialization contract
Use project-prefixed provided features, keeping requires consistent when files
move. A transient staged layout used lisp/init names; main's tree determines
the adopted share directory and later shared prefix. Do not substitute the
transient layout for the repository's actual architecture.
Load custom.el after configuration modules so user customization can override
defaults. The version policy changed from a hard error toward a warning.
An intermediate 30.2 target is historical; later main targets Emacs 31.
Resolve source loading relative to the loaded entry file. The owner explicitly
rejected resetting user-emacs-directory for tests: inject load-path instead.

## Validation limits
The source reports static/contract checks and a stub-based resolver suite
(18 cases), not complete GUI startup or dependency availability. Two trailing
whitespace findings were noted without a supported final resolution here.
The real-configuration test/startup-source tail is incomplete in this source.
No tests are inferred from a proposal or interrupted command.

## Handoff
The recoverable source scope is distilled. Formal integration should adopt the
display and loading contracts only at the relevant main-tree boundary, with
the completed packaging startup evidence considered separately.
