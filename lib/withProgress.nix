{ lib }:
{
  name,
  interval ? 10,
  text,
}:
assert builtins.isString name && name != "";
assert builtins.isInt interval && interval > 0;
assert builtins.isString text || builtins.isPath text;
''
  (
    if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3) )); then
      printf 'withProgress: Bash >= 5.3 required, found %s\n' "$BASH_VERSION" >&2
      exit 2
    fi

    progress_name=${lib.escapeShellArg name}
    progress_interval=${toString interval}
    progress_start_realtime=''${EPOCHREALTIME/./}
    progress_start_monotonic=$BASH_MONOSECONDS

    progress_elapsed() {
      local realtime=''${EPOCHREALTIME/./}
      local monotonic=$BASH_MONOSECONDS
      local elapsed_realtime=$((realtime - progress_start_realtime))
      local elapsed_monotonic=$((monotonic - progress_start_monotonic))
      local sign=""

      if (( elapsed_realtime < 0 )); then
        sign=-
        elapsed_realtime=$((-elapsed_realtime))
      fi

      printf 'realtime: %s%d.%06ds, monotonic: %ds' \
        "$sign" "$((elapsed_realtime / 1000000))" \
        "$((elapsed_realtime % 1000000))" "$elapsed_monotonic"
    }

    printf '[%s] started\n' "$progress_name" >&2 || :

    coproc progress_heartbeat {
      while true; do
        if IFS= read -r -t "$progress_interval" progress_unused; then
          continue
        else
          progress_status=$?
        fi

        if (( progress_status <= 128 )); then
          break
        fi

        printf '[%s] still running (%s)\n' "$progress_name" "$(progress_elapsed)" >&2 || :
      done
    }

    progress_pid=$progress_heartbeat_PID
    progress_fd=''${progress_heartbeat[1]}

    progress_finish() {
      local status=$1
      local elapsed
      elapsed=$(progress_elapsed)

      exec {progress_fd}>&-
      wait "$progress_pid" 2>/dev/null || :

      if (( status == 0 )); then
        printf '[%s] passed (%s)\n' "$progress_name" "$elapsed" >&2 || :
      else
        printf '[%s] failed (%s, exit status %d)\n' "$progress_name" "$elapsed" "$status" >&2 || :
      fi

      exit "$status"
    }

    trap 'progress_finish "$?"' EXIT

    (
      :
      ${if builtins.isPath text then builtins.readFile text else text}
    )
  )
''
