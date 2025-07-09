{ pkgs ? import <nixpkgs> {}, }:

(pkgs.mkShell {
  name = "linkr";

  packages = [
    # Python Packages
    (pkgs.python313.withPackages (pps: with pps; [
      click
    ]))
  ];
})
