{ pkgs ? import <nixpkgs> {} }:

let

  # Specific versions discovered by observing file WORKSPACE

  cpuinfo = pkgs.callPackage ./cpuinfo-cebb093.nix { inherit pkgs; };

  pthreadpool = pkgs.callPackage ./pthreadpool-c2ba5c5.nix { inherit pkgs; };

  xnnpack-src-rev = "51a0103656eff6fc9bfd39a4597923c4b542c883";

  xnnpack-src = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "XNNPACK";
    rev = xnnpack-src-rev;
    hash = "sha256-nhowllqv/hBs7xHdTwbWtiKJ1mvAYsVIyIZ35ZGsmkg=";
  };

  xnnpack = pkgs.stdenv.mkDerivation {
    pname = "xnnpack";
    version = xnnpack-src-rev;
    src = xnnpack-src;

    nativeBuildInputs = [
      pkgs.cmake
      pkgs.python3
      cpuinfo
      pthreadpool
    ];

    cmakeFlags = [
      "-DXNNPACK_USE_SYSTEM_LIBS=ON"
      "-DXNNPACK_BUILD_TESTS=OFF"
      "-DXNNPACK_BUILD_BENCHMARKS=OFF"

      # This isn't technically the source directory
      # But, if not specified, it will get confused where the .../include dir is
      "-DCPUINFO_SOURCE_DIR=${cpuinfo}"

    ];

  };

in
  xnnpack

