# Version of nixpkgs we want to use; this one contains
# LTS-8.3, as defined here:
#   https://github.com/NixOS/nixpkgs/blob/060f7cb94d236c8f1b60ab05670c5448b5be3e67/pkgs/development/haskell-modules/configuration-hackage2nix.yaml#L41
with import (fetchTarball https://github.com/NixOS/nixpkgs/archive/8bed8fb53227932886ab23e5f5f9eabe139f8e9f.tar.gz) { };

let
  hsPkgs = haskell.packages.ghc802;

  sourcesFilter = name: type:
    let
      baseName = baseNameOf (toString name);
    in !(
      (type == "directory" && (baseName == ".git" || baseName == ".stack-work"))
    );
in
  haskell.lib.buildStackProject {
    name = "stack-nix-caching-example";
    srcs = builtins.filterSource sourcesFilter ./.; # note https://github.com/NixOS/nix/issues/1305
    ghc = hsPkgs.ghc;
    buildInputs = [
      stack
      (haskellPackages.ghcWithPackages (pkgs: [
        pkgs.cryptonite
      ]))
    ];
  }
