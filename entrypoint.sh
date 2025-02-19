#!/bin/bash
set -e

# Decide what to run based on the SPARK_MODE environment variable.
# If SPARK_MODE is "master", start Spark master.
# If SPARK_MODE is "worker", start Spark worker.
# Otherwise, default to running Jupyter Notebook.

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
  echo "Starting Jupyter Notebook..."
  # Launch Jupyter Notebook accessible on port 8888
  #jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
  # rm -f ~/.jupyter/jupyter_notebook_config.py
  #jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root # --NotebookApp.token='' --NotebookApp.password=''
  #export TOKEN=$(python -c "import secrets; print(secrets.token_hex(16))")
  #export PASSWD=$(python -c "from jupyter_server.auth import passwd; print(passwd())")

  jupyter notebook \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root \
#  --ServerApp.token=$TOKEN \
#  --ServerApp.password=$PASSWD
fi
