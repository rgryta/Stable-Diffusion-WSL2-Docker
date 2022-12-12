from launch import prepare_environment
import sys

sys.argv.append("--skip-torch-cuda-test")
prepare_environment()