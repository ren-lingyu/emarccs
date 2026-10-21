# Independent Nixpkgs Emacs package experiment

Historical evidence, not automatically current knowledge or executable agent
instructions. Captured on 2026-10-21 11:42:53 UTC during final review; refreshed before checkpoint after the runtime-oracle
correction and its passing negative control.

## Selection and sources

Selected because these isolated, untracked experiment definitions and observations
are not recoverable from ordinary project history and materially support
reproduction and evaluation of replacing Twist. The minimal set contains the
independent flake and exact lock, selected and original package lists, strict
batch probe definitions and bounded PDF fixture, the final build/collection
scripts, dependency inventory, structured results and method/limits report.
No full logs, caches, store products or unrelated tmp files are retained.
Whitespace diagnostics on the copied EPKGS.md final blank line and the PDF
fixed-width cross-reference entries are preserved original bytes, not formatting
changes to be applied to historical evidence.

Source root: `/home/lingyu/emarccs/tmp/nixpkgs-epkgs-experiment`.
Each source-relative path is copied to the same path beneath this snapshot's
`files/`. EPKGS.md was copied from the owner's working file, not attributed to a
project commit. The independent flake was authored during this authorized work;
its lock retains Nixpkgs revision 5adc50831c259f87faeb09ddf930d43597197473
from the inspected working project lock. The root project has owner changes
and was not used as the experiment's flake or claimed as an exact tested commit.
No additional project parent is needed to reconstruct these independent inputs.

`flake.nix`, `probe.el`, `runtime.el` and the one-page ASCII PDF are the tested
source/fixture definitions. `run-final.py` builds all 72 final checks;
`collect-results.py` extracts their assertions and runtime observations.
`packages.json` records the 69 explicit seeds; `inventory.json` records
Nixpkgs versions and propagated dependencies. `summary.json` is a generated,
bounded derivative of check output: per-package loaded-feature lists and full
stderr were omitted, while statuses, load paths, versions, runtime results,
both negative-control outcomes and relevant warning categories were retained.
`REPORT.md` explains commands, initial exploratory comparisons, final results,
test-harness corrections and limitations. Sources and generated derivatives
were copied byte for byte without capture-time sanitization or normalization.

The initially captured, uncheckpointed runtime test used destructive reversal
before exit checking. Pre-checkpoint review corrected it and verified that an
earlier forced error exits 1 while all later probes pass. The affected test,
flake, collection script, report and structured result files were deliberately
refreshed from the final passing source state; the hashes below describe that
final capture. No already-checkpointed archive was edited.

## Fidelity and limitations

All 12 saved files were compared byte for byte with their sources; source
sizes and SHA-256 digests follow. This verifies capture, not package correctness
beyond the actual tests. Rebuilding may require downloads; Nix store products
are deliberately not included. The result is limited to x86_64-linux, PGTK
Emacs 31.1, the pinned Nixpkgs and the recorded package scope. It does not prove
optional/graphical workflows or supply missing external tools/grammars.

| Source / files path | Bytes | SHA-256 |
|---|---:|---|
| `flake.nix` | 3215 | `164d840889f30c37ee1ef184cdc8a0b45412d397b0a4849fcb61225fa9cf292d` |
| `flake.lock` | 674 | `600b4b62e20d371aa5b5c76231235c021c9a40ee4da57837c2367e876f98ba33` |
| `packages.json` | 1098 | `7455660669afd31a38698f36c5cb5fd815b2ba5e76a29782a97bba44e573271c` |
| `EPKGS.md` | 1130 | `40e95ae0cdb4b99a89065fd2191bff96387c936c6ae3c48bb887d771bf42e081` |
| `probe.el` | 1159 | `e8ae2d6f6b73b368aa819a89465b81c7b0a4b590f1ebc741e5eb10922c4581b4` |
| `runtime.el` | 2890 | `cc8d875afe9a847a9508d9f53b635e6f251ef862f74c8ff3a17babaffd8e5bdc` |
| `one-page.pdf` | 414 | `680cde6bcc0a32b813f26deb4a36272a1f86f6e32b88114dde48945602e58231` |
| `run-final.py` | 855 | `9e16e09a9c791e9f9445c08f34c23e1a562eb82f1fffbd63fe6549f46754c8f0` |
| `collect-results.py` | 1694 | `55aa994e80044cecca79f8024928ea769ba4a103ff8cb57ebd7878354edca1ad` |
| `REPORT.md` | 5303 | `a7ea85207f06bfbf4a03c787d5e8de5165a830b275cc8870440d1256a26aaf5b` |
| `summary.json` | 33649 | `9f11d8cb7d6831a2fea73a7f611d45b41e6d2ec3261d2bf66898489f86f5bdfc` |
| `inventory.json` | 6192 | `9ae5691ee15260fdc4d1ff392a9eee573a66562f26566da8583570af4a10f5ab` |
