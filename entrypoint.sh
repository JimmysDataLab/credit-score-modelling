#!/bin/bash
set -e

if [ "$SPARK_MODE" = "master" ]; then
  echo "Starting Spark Master..."
  ${SPARK_HOME}/sbin/start-master.sh
  # Keep the container running by tailing the master logs
  tail -F $SPARK_HOME/logs/*

  elif [ "$SPARK_MODE" = "worker" ]; then
  if [ -z "$SPARK_MASTER_URL" ]; then
    echo "Error: SPARK_MASTER_URL is not set for worker mode."
    exit 1
  fi
  echo "Starting Spark Worker connecting to $SPARK_MASTER_URL..."
  ${SPARK_HOME}/sbin/start-worker.sh $SPARK_MASTER_URL
  # Keep the container running by tailing the worker logs
  tail -F $SPARK_HOME/logs/*
