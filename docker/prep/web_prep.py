from webui import initialize
from modules.launch_utils import args

args.skip_torch_cuda_test=True

initialize.imports()
initialize.initialize()