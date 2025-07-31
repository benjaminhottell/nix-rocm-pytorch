{ pkgs ? import <nixpkgs> {} }:

let

  # Specific versions discovered by observing file WORKSPACE

  fxdiv = pkgs.callPackage ./fxdiv-63058ef.nix { inherit pkgs; };

  pthreadpool-src-rev = "c2ba5c50bb58d1397b693740cf75fad836a0d1bf";

  pthreadpool-src = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "pthreadpool";
    rev = pthreadpool-src-rev;
    hash = "sha256-aAoOCv6rzMsgP4wbcOsmB102SZJp759wK4Hu+zm/6xM=";
  };

  pthreadpool = pkgs.stdenv.mkDerivation {
    pname = "pthreadpool";
    version = pthreadpool-src-rev;
    src = pthreadpool-src;

    nativeBuildInputs = [
      pkgs.cmake
      fxdiv.src
    ];

    cmakeFlags = [

      # Sidesteps need for google test
      "-DPTHREADPOOL_BUILD_TESTS=off"

      # Sidesteps need for google benchmark
      "-DPTHREADPOOL_BUILD_BENCHMARKS=off"

      "-DFXDIV_SOURCE_DIR=${fxdiv.src}"

    ];

  };

in
  pthreadpool

