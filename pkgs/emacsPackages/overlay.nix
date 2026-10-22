{ descendantOverlay }: final_: prev_: {

  emacsPackagesFor = emacs_: (prev_.emacsPackagesFor emacs_).overrideScope descendantOverlay;

}
