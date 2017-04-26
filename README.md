# Example of how to use nix binary packages with `stack`

[`nixpkgs`](https://github.com/NixOS/nixpkgs) builds Haskell packages as binary packages.

[`stack`](https://haskellstack.org) can use them to save lots of compilation time for dependencies.

You simply have to ensure that the Stackage LTS version in `stack.yaml` is the same as in the nixpkgs you use (see top of `default.nix`).

## Try it

Incremental build with stack:

```
stack --nix build
```

Full build with with stack inside nix-build, generating a nix package (last line of output):

```
nix-build
```
