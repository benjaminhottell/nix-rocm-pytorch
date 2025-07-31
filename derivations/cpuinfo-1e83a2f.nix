{ pkgs ? import <nixpkgs> {} }:

let

  # Dependency versions discovered by running without -DUSE_SYSTEM_LIBS and observing what it tries to download

  cpuinfo-src-rev = "1e83a2fdd3102f65c6f1fb602c1b320486218a99";

  cpuinfo-src = pkgs.fetchFromGitHub {
    owner = "pytorch";
    repo = "cpuinfo";
    rev = cpuinfo-src-rev;
    hash = "sha256-28cFACca+NYE8oKlP5aWXNCLeEjhWqJ6gRnFI+VxDvg=";
  };

  cpuinfo = pkgs.stdenv.mkDerivation {
    pname = "cpuinfo";
    version = cpuinfo-src-rev;
    src = cpuinfo-src;

    nativeBuildInputs = [
      pkgs.cmake
    ];

    cmakeFlags = [
      "-DCPUINFO_BUILD_UNIT_TESTS=OFF"
      "-DCPUINFO_BUILD_MOCK_TESTS=OFF"
      "-DCPUINFO_BUILD_BENCHMARKS=OFF"
    ];

  };

in
  cpuinfo

