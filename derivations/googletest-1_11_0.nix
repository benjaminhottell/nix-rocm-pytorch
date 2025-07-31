{ pkgs ? import <nixpkgs> {} }:

let

  googletest-src-rev = "release-1.11.0";
  # aka. e2239ee6043f73722e7aa812a459f54a28552929

  googletest-src = pkgs.fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = googletest-src-rev;
    hash = "sha256-SjlJxushfry13RGA7BCjYC9oZqV4z6x8dOiHfl/wpF0=";
  };

  googletest = pkgs.stdenv.mkDerivation {
    pname = "googletest";
    version = googletest-src-rev;
    src = googletest-src;

    nativeBuildInputs = [
      pkgs.cmake
    ];

    cmakeFlags = [
      # Without this flag, it will try joining the absolute path of $out with the absolute path of $out/include, resulting in an invalid path
      "-DCMAKE_INSTALL_INCLUDEDIR=include"
    ];

  };

in
  googletest

