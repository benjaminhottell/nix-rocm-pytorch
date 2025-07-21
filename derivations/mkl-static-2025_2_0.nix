{ pkgs ? import <nixpkgs> {} }:

let

  mkl-static = pkgs.python312Packages.buildPythonPackage {
    pname = "mkl-static";
    version = "2025.2.0";
    format = "wheel";
    src = pkgs.python312Packages.fetchPypi {
      pname = "mkl_static";
      version = "2025.2.0";
      format = "wheel";
      platform = "win_amd64";
      hash = "sha256-jmGc4bd+6eJeH3APc4EwGOsf1FBBvV8yh7UlOvxXxVU=";
    };
  };

in
  mkl-static

