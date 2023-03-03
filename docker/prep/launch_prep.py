from launch import prepare_environment
import sys

sys.argv.append("--skip-torch-cuda-test")
sys.argv.append("--xformers")
prepare_environment()