{ pkgs ? import <nixpkgs> {} }:

let

  setuptools = pkgs.python312Packages.buildPythonPackage {
    pname = "setuptools";
    version = "79.0.1";
    format = "wheel";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/0d/6d/b4752b044bf94cb802d88a888dc7d288baaf77d7910b7dedda74b5ceea0c/setuptools-79.0.1-py3-none-any.whl";
      hash = "sha256-4UfAVJ8ndnujYvnaQ06rnF3ABF1TBP62AqCvABCJ/FE=";
    };
  };

in
  setuptools

