{ pkgs ? import <nixpkgs> {} }:
let

  # Version specified in requirements as: <80.0
  setuptools = pkgs.callPackage ./setuptools-79_0_1.nix { inherit pkgs; };

  # Latest versions at time of writing this file
  mkl-static = pkgs.callPackage ./mkl-static-2025_2_0.nix { inherit pkgs; };
  mkl-include = pkgs.callPackage ./mkl-include-2025_2_0.nix { inherit pkgs; };

  # The python instance with pytorch's dependencies installed
  python-build = (pkgs.python312.withPackages(pypkgs: [
    pypkgs.build
    pypkgs.pip

    # Declared in pytorch docs
    mkl-static
    mkl-include

    # Discovered by running and letting it crash
    setuptools

    # Discovered by running and letting it crash
    pypkgs.numpy
    pypkgs.requests
    pypkgs.typing-extensions
    pypkgs.pyyaml
    pypkgs.six
    pypkgs.cmake
    pypkgs.ninja
    pypkgs.filelock
    pypkgs.sympy
    pypkgs.networkx
    pypkgs.jinja2
    pypkgs.fsspec
  ]));

in
  python-build
