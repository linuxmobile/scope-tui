{fenix}: final: prev: {
  scope-tui = prev.callPackage ./default.nix {
    fenix = fenix;
  };
}
