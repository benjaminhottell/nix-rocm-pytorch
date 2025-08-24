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

  # Architectures to compile for
  # Try:
  #   nix-shell -p rocmPackages.rocminfo
  #   rocm_agent_enumerator
  # Semicolon separated!
  rocm-archs = "gfx1101;gfx1036";

  version = "2.8.0";

  rev = "ba56102387ef21a3b04b357e5b183d48f0afefc7";

  src = pkgs.fetchFromGitHub {
    owner = "pytorch";
    repo = "pytorch";
    rev = rev;
    fetchSubmodules = true;
    hash = "sha256-5JDYFoBe6bC9Dz143Bm/5OEOWsQxjctAR9fI4f6G2W8=";
  };

  pytorch-rocmpath = pkgs.callPackage ./pytorch-rocmpath.nix { inherit pkgs; };

  openblas = pkgs.callPackage ./openblas-0_3_30.nix { inherit pkgs; };

  # Versions observed in submodules in third_party/
  xnnpack = pkgs.callPackage ./xnnpack-51a0103.nix { inherit pkgs; };

  # The python instance with pytorch's dependencies installed
  python-build = pkgs.callPackage ./pytorch-python.nix { inherit pkgs; }; 

  pytorch-rocm = pkgs.stdenv.mkDerivation {

    name = "pytorch";
    version = version;
    src = src;

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

      # For some reason the PYTORCH_ROCM_ARCH value isn't being respected
      sed -i '315a\
              build_options["AMDGPU_TARGETS"] = "${rocm-archs}"' \
        tools/setup_helpers/cmake.py

      # Links to rocm_smi seem to be missing
      sed -i '1764a\
        # HACK: Link missing smi library\
        find_library(ROCM_SMI_LIBRARY rocm_smi64 HINTS "''\${ROCM_PATH}/lib")\
        if(ROCM_SMI_LIBRARY)\
          target_link_libraries(torch_hip PRIVATE ''\${ROCM_SMI_LIBRARY})\
        else()\
          message(FATAL_ERROR "rocm_smi64 hack could not find library, ''\${ROCM_PATH}/lib")\
        endif()' \
      caffe2/CMakeLists.txt

    '';

    configurePhase = ''
      true
    '';

    buildPhase = ''

      export ROCM_PATH="${pytorch-rocmpath}"
      export HIP_PATH="${pytorch-rocmpath}"
      export HSA_PATH="${pytorch-rocmpath}"

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
