{
  description = "Python ML development environment with CUDA and uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-gl-host.url = "github:numtide/nix-gl-host";
  };

  outputs = { self, nixpkgs, nix-gl-host }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      devShells.x86_64-linux.default = with pkgs; mkShell rec {

        packages = [
          cmake
          ninja
          cudaPackages.cudatoolkit
          cudaPackages.cuda_cudart
          cudaPackages.cuda_cuddev
          cudaPackages.cuda_cupti
          cudaPackages.cuda_nvrtc
          cudaPackages.cuda_nvtx
          cudaPackages.cudnn
          cudaPackages.libcublas
          cudaPackages.libcufft
          cudaPackages.libcurand
          cudaPackages.libcusolver
          cudaPackages.libcusparse
          cudaPackages.libnvjitlink
          cudaPackages.nccl
          nix-gl-host.defaultPackage.x86_64-linux
          uv
          python312
          zlib
        ];

        shellHook = ''
          if [ ! -f pyproject.toml ] && [ ! -f requirements.txt ]; then
            echo "No pyproject.toml or requirements.txt found. Run 'uv init' or create requirements.txt"
          elif [ -f requirements.txt ] && [ ! -d .venv ]; then
            uv venv .venv
            source .venv/bin/activate
            uv pip install -r requirements.txt
          elif [ -f pyproject.toml ] && [ ! -d .venv ]; then
            uv sync
            source .venv/bin/activate
          elif [ -d .venv ]; then
            source .venv/bin/activate
          fi
          
          export LD_LIBRARY_PATH=$(nixglhost -p):$LD_LIBRARY_PATH
          export LD_LIBRARY_PATH="${lib.makeLibraryPath packages}:$LD_LIBRARY_PATH
          export LD_LIBRARY_PATH="${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
          
          # CUDA-specific environment variables
          export CUDA_VISIBLE_DEVICES=0
          export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
          export TORCH_CUDA_ARCH_LIST=7.0
        '';
      };
    };
}
