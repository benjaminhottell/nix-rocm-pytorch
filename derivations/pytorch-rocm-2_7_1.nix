{
pkgs ? import <nixpkgs> {
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

  pytorch-src-rev = "v2.7.1";

  # Latest versions at time of writing this file

  mkl-static = pkgs.callPackage ./mkl-static-2025_2_0.nix { inherit pkgs; };

  mkl-include = pkgs.callPackage ./mkl-include-2025_2_0.nix { inherit pkgs; };

  openblas = pkgs.callPackage ./openblas-0_3_30.nix { inherit pkgs; };

  # Version specified in requirements file

  setuptools = pkgs.callPackage ./setuptools-79_0_1.nix { inherit pkgs; };

  # Versions observed in submodules in third_party/

  xnnpack = pkgs.callPackage ./xnnpack-51a0103.nix { inherit pkgs; };

  cpuinfo = pkgs.callPackage ./cpuinfo-1e83a2f.nix { inherit pkgs; };


  # Pytorch is expecting a path like /opt/rocm with many packages installed there
  # It is also not expecting symlinks

  pytorch-rocmpath = pkgs.stdenv.mkDerivation {

    name = "pytorch-rocmpath";

    propagatedBuildInputs = [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.rocm-core
      pkgs.rocmPackages.rocrand
      pkgs.rocmPackages.hiprand
      pkgs.rocmPackages.rocblas
      pkgs.rocmPackages.hipblas
      pkgs.rocmPackages.miopen
      pkgs.rocmPackages.hipfft
      pkgs.rocmPackages.hipsparse
      pkgs.rocmPackages.rocprim
      pkgs.rocmPackages.hipcub
      pkgs.rocmPackages.rocthrust
      pkgs.rocmPackages.hipsolver
      pkgs.rocmPackages.rocsolver
      pkgs.rocmPackages.hipblaslt
      pkgs.rocmPackages.rccl
      pkgs.rocmPackages.roctracer
      pkgs.rocmPackages.aotriton
      pkgs.rocmPackages.composable_kernel
    ];

    nativeBuildInputs = [
      pkgs.rsync
    ];

    unpackPhase = ''
      true
    '';

    installPhase = ''
      mkdir -p "$out"
      mkdir -p "$out"/include
      mkdir -p "$out"/bin
      mkdir -p "$out"/lib

      rsync -rl "${pkgs.rocmPackages.clr}"/        "$out"/
      rsync -rl "${pkgs.rocmPackages.rocm-core}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.rocrand}"/    "$out"/
      rsync -rl "${pkgs.rocmPackages.hiprand}"/    "$out"/
      rsync -rl "${pkgs.rocmPackages.rocblas}"/    "$out"/
      rsync -rl "${pkgs.rocmPackages.hipblas}"/    "$out"/
      rsync -rl "${pkgs.rocmPackages.miopen}"/     "$out"/
      rsync -rl "${pkgs.rocmPackages.hipfft}"/     "$out"/
      rsync -rl "${pkgs.rocmPackages.hipsparse}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.rocprim}"/    "$out"/
      rsync -rl "${pkgs.rocmPackages.hipcub}"/     "$out"/
      rsync -rl "${pkgs.rocmPackages.rocthrust}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.hipsolver}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.rocsolver}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.hipblaslt}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.rccl}"/       "$out"/
      rsync -rl "${pkgs.rocmPackages.roctracer}"/  "$out"/
      rsync -rl "${pkgs.rocmPackages.aotriton}"/   "$out"/
      rsync -rl "${pkgs.rocmPackages.composable_kernel}"/ "$out"/
    '';

  };


  # The python instance with pytorch's dependencies installed
  python-build = (pkgs.python312.withPackages(pypkgs: [
    pypkgs.build
    pypkgs.pip

    # Declared in pytorch docs
    mkl-static
    mkl-include

    # Discovered by running and letting it crash
    setuptools

    # Discovered by running and letting it crash
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
  ]));


  pytorch-src = pkgs.fetchFromGitHub {
    owner = "pytorch";
    repo = "pytorch";
    rev = pytorch-src-rev;
    fetchSubmodules = true;
    hash = "sha256-wVzYx8YYoL8rVYb9DwF6ai16UzPvSO4WhNvddh09RXM=";
  };


  # Architectures to compile for
  # Try:
  #   nix-shell -p rocmPackages.rocminfo
  #   rocm_agent_enumerator
  # Semicolon separated!
  rocm-archs = "gfx1101;gfx1036";


  pytorch-rocm = pkgs.stdenv.mkDerivation {

    name = "pytorch";
    version = pytorch-src-rev;
    src = pytorch-src;

    nativeBuildInputs = [
      pkgs.git
      pkgs.cmake
      python-build
    ];

    buildInputs = [
    ];

    propagatedBuildInputs = [
      pytorch-rocmpath
      openblas
      xnnpack
      pkgs.protobuf
    ];

    dontUseCmakeConfigure = true;

    # I make sure to unset PYTHONPATH
    # The process is very sensitive to 'stray' packages leaking into the environment
    patchPhase = ''

      unset PYTHONPATH

      substituteInPlace \
        torch/csrc/jit/ir/ir.cpp \
        --replace-fail 'case cuda::set_stream:' '// case cuda::set_stream:' \
        --replace-fail 'case cuda::_set_device:' '// case cuda::set_device:' \
        --replace-fail 'case cuda::_current_device:' '// case cuda::current_device:' \
        --replace-fail 'case cuda::synchronize:' '// case cuda::synchronize:'

      # https://github.com/pytorch/pytorch/pull/159527
      substituteInPlace \
        cmake/Dependencies.cmake \
        --replace-fail \
          'if(NOT XNNPACK_LIBRARY or NOT microkernels-prod_LIBRARY)' \
          'if(NOT XNNPACK_LIBRARY OR NOT microkernels-prod_LIBRARY)'

    '';

    configurePhase = ''
      true
    '';

    buildPhase = ''

      export ROCM_PATH="${pytorch-rocmpath}"

      export ROCM_SOURCE_DIR="$ROCM_PATH"

      export AOTRITON_INSTALLED_PREFIX="$ROCM_PATH"

      export PYTORCH_ROCM_ARCH="${rocm-archs}";

      export BLAS="OpenBLAS"
      export OpenBLAS_HOME="${openblas}"

      export USE_ROCM=ON
      export USE_CUDA=OFF
      export USE_NNPACK=OFF
      export USE_GLOO=OFF
      export USE_NCCL=OFF
      export USE_SYSTEM_XNNPACK=ON

      # Pytorch tries to clone nccl even though we don't want it.
      # Here, we lie to pytorch :)
      mkdir -p third_party/nccl
      touch third_party/nccl/CMakeLists.txt

      ${python-build}/bin/python tools/amd_build/build_amd.py

      CMAKE_ONLY=1 ${python-build}/bin/python setup.py bdist_wheel

    '';

    installPhase = ''

      python -m pip install --prefix $out --no-index --no-build-isolation -v .

    '';

  };


in
  pytorch-rocm

