# nix-rocm-pytorch

This repository stores how I got [pytorch](https://github.com/pytorch/pytorch) to compile on [NixOS](https://nixos.org/), running on an AMD GPU using [ROCm](https://www.amd.com/en/products/software/rocm.html).


## Setup

In the file `derivations/pytorch-rocm-2_7_1.nix`, change `rocm-archs` to the architectures available on your system.

```nix
# Architectures to compile for
# Try:
#   nix-shell -p rocmPackages.rocminfo
#   rocm_agent_enumerator
# Semicolon separated!
rocm-archs = "gfx1101;gfx1036";
```


## Usage

Running `nix-shell` in the root directory of this repository will build pytorch and all of its dependencies.

This process will probably take a while.

Afterward, run `test.py` to verify that it is working.

