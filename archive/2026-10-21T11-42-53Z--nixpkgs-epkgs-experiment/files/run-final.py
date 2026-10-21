import json, subprocess, time
from pathlib import Path
root = Path(__file__).resolve().parent
names = json.loads((root / "packages.json").read_text()) + ["combined-forward", "combined-reverse", "negative-control"]
cmd = ["timeout", "120s", "nix", "build", "--no-link", "--json", "--keep-going", "--no-write-lock-file", "--max-jobs", "4", "--cores", "2", "-L"]
cmd += [f"path:{root}#checks.x86_64-linux.{n}" for n in names]
started = time.time()
with (root / "final-build.json").open("w") as out, (root / "final-build.log").open("w") as err:
    result = subprocess.run(cmd, stdout=out, stderr=err)
record = {"exit_code": result.returncode, "elapsed_seconds": round(time.time() - started, 2), "check_count": len(names)}
(root / "final-run.json").write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps(record))
raise SystemExit(result.returncode)
