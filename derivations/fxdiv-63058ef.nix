{ pkgs ? import <nixpkgs> {} }:

let

  # Specific versions discovered by observing file WORKSPACE

  fxdiv-src-rev = "63058eff77e11aa15bf531df5dd34395ec3017c8";

  fxdiv-src = pkgs.fetchFromGitHub {
    owner = "Maratyszcza";
    repo = "FXdiv";
    rev = fxdiv-src-rev;
    hash = "sha256-LjX5kivfHbqCIA5pF9qUvswG1gjOFo3CMpX0VR+Cn38=";
  };

  fxdiv = pkgs.stdenv.mkDerivation {
    pname = "fxdiv";
    version = fxdiv-src-rev;
    src = fxdiv-src;

    nativeBuildInputs = [
      pkgs.cmake
    ];

    cmakeFlags = [
      # Sidestep need for google test
      "-DFXDIV_BUILD_TESTS=OFF"
      # Sidestep need for google benchmark
      "-DFXDIV_BUILD_BENCHMARKS=OFF"
    ];

  };

in {
  default = fxdiv;
  fxdiv = fxdiv;
  src = fxdiv-src;
}

