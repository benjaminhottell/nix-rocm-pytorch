{ pkgs ? import <nixpkgs> {} }:
let

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
      pkgs.rocmPackages.rocm-smi
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
      rsync -rl "${pkgs.rocmPackages.rocm-smi}"/   "$out"/

      substituteInPlace "$out/lib/cmake/rocm-core/rocm-core-config.cmake" \
        --replace-fail \
          'get_filename_component(PACKAGE_PREFIX_DIR "''\${CMAKE_CURRENT_LIST_DIR}/../../../../../../" ABSOLUTE)' \
          'get_filename_component(PACKAGE_PREFIX_DIR "'"$out"'" ABSOLUTE)'

      substituteInPlace "$out/lib/cmake/rocm_smi/rocm_smi-config.cmake" \
        --replace-fail \
          'get_filename_component(PACKAGE_PREFIX_DIR "''\${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)' \
          'get_filename_component(PACKAGE_PREFIX_DIR "'"$out"'" ABSOLUTE)'
    '';

  };

in
  pytorch-rocmpath
