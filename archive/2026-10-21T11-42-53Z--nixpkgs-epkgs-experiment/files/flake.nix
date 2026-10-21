{
  inputs.nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    lib = pkgs.lib;
    base = pkgs.emacs-pgtk;
    epkgs = pkgs.emacsPackagesFor base;
    names = builtins.fromJSON (builtins.readFile ./packages.json);
    mkWrapper = ns: epkgs.withPackages (e: map (n: builtins.getAttr n e) ns);
    single = lib.genAttrs names (n: mkWrapper [ n ]);
    combined = mkWrapper names;
    mkRuntime = order: pkgs.runCommand "epkgs-runtime-${order}" {
      nativeBuildInputs = [ pkgs.coreutils ];
    } ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" "$out"
      export PATH="${pkgs.coreutils}/bin"
      export EPKGS_LIST="${./packages.json}"
      export EPKGS_PDF="${./one-page.pdf}"
      ${lib.optionalString (order == "reverse") "export EPKGS_REVERSE=1"}
      timeout --kill-after=3s 45s ${combined}/bin/emacs --batch -q --load ${./runtime.el} > "$out/result.json" 2> "$out/stderr.log"
    '';
    negativeControl = pkgs.runCommand "epkgs-negative-control" {
      nativeBuildInputs = [ pkgs.coreutils ];
    } ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" "$out"
      export PATH="${pkgs.coreutils}/bin"
      export EPKGS_TARGET="epkgs-intentionally-missing-library"
      set +e
      timeout --kill-after=3s 30s ${single.org}/bin/emacs --batch -q --load ${./probe.el} > "$out/result.json" 2> "$out/stderr.log"
      status=$?
      set -e
      test "$status" -eq 1
      ${pkgs.gnugrep}/bin/grep -Fq '"status":"fail"' "$out/result.json"
      ${pkgs.gnugrep}/bin/grep -Fq 'Library not found' "$out/result.json"
      printf '["epkgs-intentionally-missing-library"]' > "$TMPDIR/missing.json"
      export EPKGS_LIST="$TMPDIR/missing.json"
      export EPKGS_PDF="${./one-page.pdf}"
      set +e
      timeout --kill-after=3s 45s ${combined}/bin/emacs --batch -q --load ${./runtime.el} > "$out/runtime-result.json" 2> "$out/runtime-stderr.log"
      status=$?
      set -e
      test "$status" -eq 1
      ${pkgs.gnugrep}/bin/grep -Fq '"test":"coexistence","status":"fail"' "$out/runtime-result.json"
      ${pkgs.gnugrep}/bin/grep -Fq '"test":"auctex-mode","status":"pass"' "$out/runtime-result.json"
    '';
    mkCheck = n: wrapper: pkgs.runCommand "epkgs-probe-${n}" {
      nativeBuildInputs = [ pkgs.coreutils ];
    } ''
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME" "$out"
      export PATH="${pkgs.coreutils}/bin"
      export EPKGS_TARGET="${n}"
      timeout --kill-after=3s 30s ${wrapper}/bin/emacs --batch -q --load ${./probe.el} > "$out/result.json" 2> "$out/stderr.log"
    '';
  in {
    packages.${system} = single // { default = combined; inherit combined; };
    checks.${system} = lib.mapAttrs mkCheck single // {
      combined-forward = mkRuntime "forward";
      combined-reverse = mkRuntime "reverse";
      negative-control = negativeControl;
    };
    inventory = map (n: { name = n; exists = builtins.hasAttr n epkgs; version = epkgs.${n}.version or null; dependencies = map (d: if d == null then null else d.pname or d.name) (epkgs.${n}.propagatedBuildInputs or []); }) names;
  };
}
