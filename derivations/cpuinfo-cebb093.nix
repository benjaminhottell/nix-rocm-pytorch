{ pkgs ? import <nixpkgs> {} }:

let

  # Dependency versions discovered by running without -DUSE_SYSTEM_LIBS and observing what it tries to download

  cpuinfo-src-rev = "cebb0933058d7f181c979afd50601dc311e1bf8c";

  cpuinfo-src = pkgs.fetchFromGitHub {
    owner = "pytorch";
    repo = "cpuinfo";
    rev = cpuinfo-src-rev;
    hash = "sha256-MlJZmgwHt6+hJHdl8lKOTeaTT+PTOgRHfmCCjn0a3Zc=";
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

