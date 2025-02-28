#!/bin/bash
set -e

# Decide what to run based on the SPARK_MODE environment variable.
# If SPARK_MODE is "master", start Spark master.
# If SPARK_MODE is "worker", start Spark worker.
# Otherwise, default to running Jupyter Notebook.

# Ensure that the conda base is loaded.
source ${CONDA_HOME}/bin/activate spark_env

# Now run your commands in the activated environment.
exec "$@"


if [ "$SPARK_MODE" = "master" ]; then
  echo "Starting Spark Master..."
  $SPARK_HOME/sbin/start-master.sh

  # Keep the container running by tailing the master logs
  tail -F $SPARK_HOME/logs/*
elif [ "$SPARK_MODE" = "worker" ]; then
  if [ -z "$SPARK_MASTER_URL" ]; then
    echo "Error: SPARK_MASTER_URL is not set for worker mode."
    exit 1
  fi
  echo "Starting Spark Worker connecting to $SPARK_MASTER_URL..."
  $SPARK_HOME/sbin/start-worker.sh $SPARK_MASTER_URL

  # Keep the container running by tailing the worker logs
  tail -F $SPARK_HOME/logs/*
else
  # echo "Downloading Raw Data..."
  # python /app/scripts/stage_data.py


  echo "Starting Jupyter Notebook..."
  jupyter notebook \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \

fi
