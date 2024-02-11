#!/bin/bash
source $SD_PROJECT/venv/bin/activate

mv web_prep.py $SD_PROJECT/web_prep.py

cd $SD_PROJECT
python3.11 web_prep.py && rm web_prep.py