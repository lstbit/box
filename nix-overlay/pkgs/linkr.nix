{ pkgs ? import <nixpkgs> {} }:

let
  repoSrc = pkgs.fetchFromGitHub {
    repo = "box";
    owner = "lstbit";
    rev = "linkr/0.0";
    hash = "sha256-Y+91e8Fru0dInx459Sy14OeMcQ5M3LriS7/t0lr21Fk=";
  };
in
pkgs.python313Packages.buildPythonApplication {
  pname = "linkr";
  version = "0.0";
  pyproject = true;

  src = repoSrc + "/linkr";

  build-system = with pkgs.python313Packages; [
    setuptools
  ];

  dependencies = with pkgs.python313Packages; [
    click
  ];

  # hack to install to with the name linkr instead of linkr.py
  postInstall = ''
    mv $out/bin/linkr.py $out/bin/linkr
  '';
}
