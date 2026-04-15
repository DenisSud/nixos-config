{
  description = "Local flake templates for common development environments";

  outputs = { self }: {
    templates = {
      python-ml-cuda = {
        path = ./python-ml-cuda;
        description = "Python ML stack with CUDA, cuDNN, NCCL, and uv for PyTorch development";
      };
    };
  };
}
