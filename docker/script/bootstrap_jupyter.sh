#!/bin/sh

set -e

cd /usr/local/airflow/

python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip install jupyterlab
pip install -r /requirements.txt
