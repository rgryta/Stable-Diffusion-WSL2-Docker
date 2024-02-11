from webui import initialize
from modules import shared
from modules.launch_utils import args

args.skip_torch_cuda_test=True
shared.cmd_opts.no_download_sd_model=True

initialize.imports()
initialize.initialize()