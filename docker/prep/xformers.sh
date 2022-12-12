#!/bin/bash
source $SD_PROJECT/venv/bin/activate

cd $SD_HOME
git clone https://github.com/facebookresearch/xformers/
cd xformers
git submodule update --init --recursive
pip install --verbose --no-deps -e .
python3 setup.py bdist_wheel --universal