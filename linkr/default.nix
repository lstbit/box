{ pkgs ? import <nixpkgs> {} }:

let
  repoSrc = pkgs.fetchFromGitHub {
    repo = "box";
    owner = "lstbit";
    rev = "ebc601dd289180b5a9e42c68caf4981a2d548d23";
    sha256 = "sha256-Twf/7al6ap5DSOvqomS/gK4ZNYEcsr9MMcn0UR8c9BU=";
  };
in
pkgs.python313Packages.buildPythonApplication {
  pname = "linkr";
  version = "0.0";
  pyproject = true;

  # src = repoSrc + "/linkr";
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
