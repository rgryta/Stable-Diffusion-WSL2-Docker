#!/bin/bash
source $SD_PROJECT/venv/bin/activate

python3.11 -m pip install wheel triton torch==2.1.0 torchvision==0.16 xformers==0.0.22.post7
mv launch_prep.py $SD_PROJECT/launch_prep.py

cd $SD_PROJECT
python3.11 -m pip install -r requirements.txt
python3.11 launch_prep.py && rm launch_prep.py