{ pkgs ? import <nixpkgs> {} }:

let

  openblas-src = pkgs.fetchFromGitHub {
    owner = "OpenMathLib";
    repo = "OpenBLAS";
    rev = "v0.3.30";
    hash = "sha256-foP2OXUL6ttgYvCxLsxUiVdkPoTvGiHomdNudbSUmSE=";
  };

  openblas = pkgs.stdenv.mkDerivation {
    pname = "openblas";
    version = "0.3.30";
    src = openblas-src;

    buildPhase = ''
      make -j $(nproc)
    '';

    installPhase = ''
      mkdir -p $out
      export PREFIX=$out
      make install
    '';

  };

in
  openblas

