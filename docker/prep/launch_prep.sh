#!/bin/bash
source $SD_PROJECT/venv/bin/activate

python3 -m pip install wheel triton
mv launch_prep.py $SD_PROJECT/launch_prep.py

cd $SD_PROJECT
python3 -m pip install -r requirements.txt
python3 launch_prep.py && rm launch_prep.py

cd $SD_HOME/prep
./xformers.sh