from launch import prepare_environment, args

args.skip_torch_cuda_test=True
args.xformers=True

prepare_environment()