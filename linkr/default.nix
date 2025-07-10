{ pkgs ? import <nixpkgs> {} }:

# This bulid script is used for local development purposes only
# for the version that gets installed check box/nix-overlay/pkgs/linkr

pkgs.python313Packages.buildPythonApplication {
  pname = "linkr";
  version = "0.0";
  pyproject = true;

  src = ./.;

  build-system = with pkgs.python313Packages; [
    setuptools
  ];

  dependencies = with pkgs.python313Packages; [
    click
  ];

  postInstall = ''
    mv $out/bin/linkr.py $out/bin/linkr
  '';
}
