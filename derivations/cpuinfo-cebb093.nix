{ pkgs ? import <nixpkgs> {} }:

let

  rev = "cebb0933058d7f181c979afd50601dc311e1bf8c";

  src = pkgs.fetchFromGitHub {
    owner = "pytorch";
    repo = "cpuinfo";
    rev = rev;
    hash = "sha256-MlJZmgwHt6+hJHdl8lKOTeaTT+PTOgRHfmCCjn0a3Zc=";
  };

  cpuinfo = pkgs.stdenv.mkDerivation {
    pname = "cpuinfo";
    version = rev;
    src = src;

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
