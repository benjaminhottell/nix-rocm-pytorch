{ pkgs ? import <nixpkgs> {} }:

let

  mkl-include = pkgs.python312Packages.buildPythonPackage {
    pname = "mkl-include";
    version = "2025.2.0";
    format = "wheel";
    src = pkgs.python312Packages.fetchPypi {
      pname = "mkl_include";
      version = "2025.2.0";
      format = "wheel";
      platform = "win_amd64";
      hash = "sha256-0gMFtK36NkB6gI7GoW3F1tpvi5y0qWvcwOCrMjnEOBY=";
    };
  };

in
  mkl-include

