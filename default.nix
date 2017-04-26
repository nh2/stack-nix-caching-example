# Version of nixpkgs we want to use; this one contains
# LTS-8.3, as defined here:
#   https://github.com/NixOS/nixpkgs/blob/139b1377d4f9a8c943af79dd245ea9ecf6536567/pkgs/development/haskell-modules/configuration-hackage2nix.yaml#L41
with import (fetchTarball https://github.com/NixOS/nixpkgs/archive/139b1377d4f9a8c943af79dd245ea9ecf6536567.tar.gz) { };

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

    # These should probably be fixed (adding --system-ghc) upstream in:
    #   https://github.com/nh2/nixpkgs/blob/139b1377d4f9a8c943af79dd245ea9ecf6536567/pkgs/development/haskell-modules/generic-stack-builder.nix#L42
    buildPhase = "stack --system-ghc build";
    checkPhase = "stack --system-ghc test";
    installPhase = "stack --system-ghc --local-bin-path=$out/bin build --copy-bins";
  }
