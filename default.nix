# Version of nixpkgs we want to use; this one contains
# LTS-8.3, as defined here:
#   https://github.com/NixOS/nixpkgs/blob/8bed8fb53227932886ab23e5f5f9eabe139f8e9f/pkgs/development/haskell-modules/configuration-hackage2nix.yaml#L41
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

    # Fix to remove `stack build` from `configurePhase`:
    configurePhase = ''
      export STACK_ROOT=$NIX_BUILD_TOP/.stack
    '';
    # These should probably be fixed (adding --system-ghc) upstream in:
    #   https://github.com/nh2/nixpkgs/blob/8bed8fb53227932886ab23e5f5f9eabe139f8e9f/pkgs/development/haskell-modules/generic-stack-builder.nix#L42
    buildPhase = "stack --system-ghc build";
    checkPhase = "stack --system-ghc test";
    installPhase = "stack --system-ghc --local-bin-path=$out/bin build --copy-bins";
  }
