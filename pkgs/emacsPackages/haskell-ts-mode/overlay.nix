{ }: final_: prev_: {
  haskell-ts-mode = prev_.haskell-ts-mode.overrideAttrs (old_: {
    preInstall = (old_.preInstall or "") + ''
      tar -xf "$src"
      substituteInPlace "haskell-ts-mode-${old_.version}/haskell-ts-mode.el" \
        --replace-fail type_synomym type_synonym
      tar -cf "$TMPDIR/haskell-ts-mode-patched.tar" "haskell-ts-mode-${old_.version}"
      src="$TMPDIR/haskell-ts-mode-patched.tar"
    '';
  });
}
