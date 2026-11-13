{
  runCommand,
  writeText,
  withProgress,
}:
runCommand "with-progress"
  {
    successCase = writeText "with-progress-success.sh" ''
      set -euo pipefail

      fixture_message=path-input
      original_directory=$PWD
      progress_name=outer

      ${withProgress {
        name = "success";
        text = ''
          printf 'original stdout\n'
          printf 'original stderr\n' >&2
          printf 'redirected output\n' > redirected
          progress_name=inner
          cd /tmp
          trap 'printf "inner exit\n"' EXIT
        '';
      }}

      test "$progress_name" = outer
      test "$PWD" = "$original_directory"

      ${withProgress {
        name = "path-input";
        text = ./fixture.sh;
      }}

      ${withProgress {
        name = "empty";
        text = "";
      }}

      ${withProgress {
        name = "comment-only";
        text = "# comment";
      }}

      ${withProgress {
        name = "no-errexit";
        text = ''
          set +e
          false
          printf 'continued\n'
        '';
      }}
    '';

    failureCase = writeText "with-progress-failure.sh" (withProgress {
      name = "failure";
      text = ''
        printf 'before failure\n'
        false
        printf 'must not execute\n'
      '';
    });

    execCase = writeText "with-progress-exec.sh" (withProgress {
      name = "exec";
      text = "exec bash -c 'exit 42'";
    });

    slowCase = writeText "with-progress-slow.sh" (withProgress {
      name = "slow";
      interval = 1;
      text = ''
        printf 'before sleep\n'
        sleep 2.5
        printf 'after sleep\n'
      '';
    });

    # Test that a name is shell-escaped, not evaluated as Bash code.
    quotedCase = writeText "with-progress-quoted.sh" (withProgress {
      name = "quoted '$(touch unexpected)'";
      text = ":";
    });
  }
  ''
    bash "$successCase" > success.stdout 2> success.stderr
    grep -Fx 'original stdout' success.stdout
    grep -Fx 'original stderr' success.stderr
    grep -Fx 'redirected output' redirected
    grep -Fx 'inner exit' success.stdout
    grep -Fx 'path-input' success.stdout
    grep -Fx 'continued' success.stdout

    for name in success path-input empty comment-only no-errexit; do
      grep -Fx "[$name] started" success.stderr
      grep -Ex "\[$name\] passed \(realtime: -?[0-9]+\.[0-9]{6}s, monotonic: -?[0-9]+s\)" success.stderr
    done

    status=0
    bash -e "$failureCase" > failure.stdout 2> failure.stderr || status=$?
    test "$status" -eq 1
    grep -Fx 'before failure' failure.stdout
    if grep -F 'must not execute' failure.stdout; then
      exit 1
    fi
    grep -Ex '\[failure\] failed \(realtime: -?[0-9]+\.[0-9]{6}s, monotonic: -?[0-9]+s, exit status 1\)' failure.stderr

    status=0
    bash -e "$execCase" > exec.stdout 2> exec.stderr || status=$?
    test "$status" -eq 42
    grep -Ex '\[exec\] failed \(realtime: -?[0-9]+\.[0-9]{6}s, monotonic: -?[0-9]+s, exit status 42\)' exec.stderr

    bash -e "$slowCase" > slow.log 2>&1
    grep -Fx 'before sleep' slow.log
    grep -Ex '\[slow\] still running \(realtime: -?[0-9]+\.[0-9]{6}s, monotonic: -?[0-9]+s\)' slow.log
    grep -Fx 'after sleep' slow.log
    tail -n 1 slow.log | grep -Ex '\[slow\] passed \(realtime: -?[0-9]+\.[0-9]{6}s, monotonic: -?[0-9]+s\)'

    bash -e "$quotedCase" > quoted.stdout 2> quoted.stderr
    grep -Fx "[quoted '\$(touch unexpected)'] started" quoted.stderr
    test ! -e unexpected

    touch "$out"
  ''
