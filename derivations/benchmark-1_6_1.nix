{ pkgs ? import <nixpkgs> {} }:

let

  # Discovered specific version in file: WORKSPACE
  googletest = pkgs.callPackage ./googletest-1_11_0.nix { inherit pkgs; };

  benchmark-src-rev = "v1.6.1";

  benchmark-src = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "benchmark";
    rev = benchmark-src-rev;
    hash = "sha256-yUiFxi80FWBmTZgqmqTMf9oqcBeg3o4I4vKd4djyRWY=";
  };

  benchmark = pkgs.stdenv.mkDerivation {
    pname = "benchmark";
    version = benchmark-src-rev;
    src = benchmark-src;

    nativeBuildInputs = [
      pkgs.cmake
      googletest
    ];

    patchPhase = ''

      substituteInPlace \
        'cmake/benchmark.pc.in' \
        --replace-fail \
          'libdir=''${prefix}/@CMAKE_INSTALL_LIBDIR@' \
          'libdir=@CMAKE_INSTALL_LIBDIR@'

      substituteInPlace \
        'cmake/benchmark.pc.in' \
        --replace-fail \
          'includedir=''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@' \
          'includedir=@CMAKE_INSTALL_INCLUDEDIR@'

    '';

    cmakeFlags = [
      "-DBENCHMARK_USE_BUNDLED_GTEST=OFF"
    ];

  };

in
  benchmark

