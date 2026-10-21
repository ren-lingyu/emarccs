# Nixpkgs Emacs package experiment

The independent flake uses Nixpkgs revision
`5adc50831c259f87faeb09ddf930d43597197473`, `x86_64-linux`, and
`pkgs.emacs-pgtk` (Emacs 31.1). It imports no Twist, local recipes, overrides,
or Emarccs initialization. The package scope is `emacsPackagesFor base`.

## Scope and method

EPKGS.md contains 75 entries. All 69 existing targets, including unmodified
`epkgs.org`, are tested. Only six explicitly missing packages are excluded:
org-include-inline, org-roam-blog, org-roam-include, org-roam-organize,
org-texmacs and org-workbench. Dependencies of the 69 targets remain included
by Nixpkgs; this does not forbid missing targets from occurring transitively.

- Build one combined wrapper with all 69 explicitly selected attributes.
- Build 69 single-target wrappers and load each entry in a fresh batch process.
  This prevents other explicit seeds from masking undeclared dependencies.
- Load the same 69 entries individually in fresh processes using the combined
  wrapper (exploratory comparison).
- Load all entries together in both list order and reverse order, with real
  Org parsing, Org-roam SQLite SELECT, PDF helper page-count query and AUCTeX
  LaTeX-mode creation in each process.
- Verify a deliberately nonexistent library exits 1 and records failure.
  Also force an early runtime failure with later successful checks and require
  exit 1, ensuring the complete runtime result list is checked.

Batch processes use `--batch -q`, preserving Nix wrapper site initialization,
a fresh HOME, and a controlled PATH. They never load personal configuration.
Single-target checks have a 30s timeout, combined runtime checks 45s, Nix
build invocations 120s. The per-target build group uses at most four concurrent
builders and two cores per builder. Runtime tests use only the selected 69
packages; coreutils/grep are test harness tools, not added Emacs targets.
Attribute and library names are distinct for AUCTeX, whose entry is tex-site.

## Results

- Combined wrapper build passed.
- 69/69 single-target wrapper builds and entry loads passed.
- 69/69 fresh entry loads in the combined wrapper passed.
- Forward/reverse shared-process loads and all five runtime probes per order
  passed (10 observations in total).
- The final 72 Nix check derivations built successfully: 69 package probes,
  two combined runtime probes and one negative control. Probe errors produce
  nonzero process exits; the negative control verifies that detection.
- Org resolved to Nixpkgs Org 9.8.10, not Emacs' bundled Org. This does not
  satisfy EPKGS.md's requested 10.0-pre version. No repackaging was attempted.
- Org-roam database query returned ((1)); PDF Tools' packaged epdfinfo parsed
  the one-page fixture successfully without relying on host PATH.
- Tree-sitter itself is available, but none of the five probed grammars
  (nix, haskell, bash, json, python) is available from this package set.
  haskell-ts-mode emits a missing-grammar warning while still loading.
- In the controlled PATH, rg, git, diff, find, latex, sbcl and epdfinfo are
  not found by executable-find. The helper nevertheless works through its
  package-relative path. External tools for editing workflows must be handled
  separately; this experiment does not prove their absence from the entire
  Nix closure or that all are necessarily required by every package.
- Org GTD emits its v3-to-v4 migration/configuration notice. No migration or
  configuration changes were performed.

The initial dependency-report script did not account for null entries in
propagatedBuildInputs; that reporting bug was corrected. The first strict
negative-control check lacked grep after PATH isolation and failed; using
an explicit grep path fixed the test harness. Review also found that destructive list reversal before exit checking could
mask earlier runtime failures. The result collector had independently checked
all observations, so reported successes remain valid. Replacing nreverse with
reverse and adding the early-failure/late-success negative control fixed the
oracle. Final checks passed after these corrections. These were test-harness
issues, not package build/load failures.

## Reproduction and evidence limits

From this independent directory, run:

```sh
timeout 120s nix build --no-link --print-out-paths --no-write-lock-file path:$PWD#combined
python3 run-final.py
python3 collect-results.py
```

`summary.json` preserves final structured observations. `inventory.json`
records versions and Nixpkgs-declared propagated inputs, including null items.
The copied EPKGS.md records the actual selection input. The final-run script
writes final-build.json and final-run.json locally, which the collector reads;
store-path outputs need rebuilding if garbage collected.

The initial combined-wrapper build and exploratory individual combined loads
were performed separately; final check derivations reproduce the isolated
entry loads and shared-process functional probes. This is not a proof of all
optional/deferred code paths, external applications, graphical behavior,
Tree-sitter language functionality, or compatibility with Emarccs' full config.
Only x86_64-linux PGTK was tested. No root flake, input declaration, project
index, package override or lock was changed by the experiment.
