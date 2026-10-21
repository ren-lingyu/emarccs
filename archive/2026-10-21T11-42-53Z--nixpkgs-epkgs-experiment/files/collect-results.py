import json
from pathlib import Path
root = Path(__file__).resolve().parent
builds = json.loads((root / "final-build.json").read_text())
packages, runtime, negative, runtime_negative = [], [], None, None
for build in builds:
    out = Path(build["outputs"]["out"])
    data = json.loads((out / "result.json").read_text())
    if "checks" in data:
        runtime.append(data)
    elif data.get("package") == "epkgs-intentionally-missing-library":
        negative = data
        runtime_negative = json.loads((out / "runtime-result.json").read_text())
    else:
        packages.append({k: v for k, v in data.items() if k != "new_features"})
packages.sort(key=lambda item: item["package"])
assert len(packages) == 69
assert all(item["status"] == "pass" for item in packages)
assert len(runtime) == 2
assert all(c["status"] == "pass" for run in runtime for c in run["checks"])
assert negative["status"] == "fail"
assert runtime_negative["checks"][0]["status"] == "fail"
assert runtime_negative["checks"][-1]["status"] == "pass"
summary = {"nixpkgs_revision": json.loads((root / "flake.lock").read_text())["nodes"]["nixpkgs"]["locked"]["rev"], "platform": "x86_64-linux", "base": "emacs-pgtk", "build": json.loads((root / "final-run.json").read_text()), "packages": packages, "runtime": runtime, "negative_control": negative, "runtime_negative_control": runtime_negative, "warnings": ["haskell-ts-mode loads but warns that the Haskell grammar is missing", "org-gtd emits its v3-to-v4 configuration/data migration notice"]}
(root / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print("69 package probes and 10 runtime checks passed; negative control detects a missing library")
