from webui import initialize
import sys

sys.argv.append("--skip-torch-cuda-test")
initialize()