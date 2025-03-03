#!/bin/bash
set -e

source "${CONDA_HOME}/bin/activate" spark_env

echo "Starting Jupyter Notebook..."
exec jupyter notebook \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root