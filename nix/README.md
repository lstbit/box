nix stuff

overlay.nix:

personal packages and things.

package list:
- linkr@0.0


example usage:
shell.nix
```nix
let
  tarball = builtins.fetchTarball {
    url = "https://github.com/lstbit/box/archive/refs/heads/main.tar.gz";
    sha256 = "sha256-3ilDXOInRhx3GcDw8RVjytGjssfjRwmROyNhwf1ZWU8=";
  };
  overlay = import ("${tarball}/nix/overlay");
in
{ pkgs ? import <nixpkgs> { overlays = [ overlay ];}}:

pkgs.mkShell {
  buildInputs = with pkgs; [ linkr ];
}
```


