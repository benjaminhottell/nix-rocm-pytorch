{ pkgs ? import <nixpkgs> {
    overlays = [
      # https://github.com/NixOS/nixpkgs/issues/421822
      (final: prev: { # Overlay to disable buildDocs for rocdbgapi
        rocmPackages = prev.rocmPackages.overrideScope (rocmFinal: rocmPrev: {
          rocdbgapi = rocmPrev.rocdbgapi.override { buildDocs = false; };
        });
      })
    ];
  }
}:

let

  rocm-pytorch = pkgs.callPackage ./derivations/pytorch-rocm-2_7_1.nix {};

  shell = pkgs.mkShell {

    packages = [

      (pkgs.python312.withPackages (pypkgs: [

        # needed by pytorch
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

      ]))

      # Useful for troubleshooting rocm
      pkgs.rocmPackages.rocminfo

    ];

    buildInputs = [
      rocm-pytorch
    ];

    shellHook = ''
      export PYTHONPATH="${rocm-pytorch}/lib/python3.12/site-packages:$PYTHONPATH"
    '';

  };


in
  shell

