#!/bin/bash
set -e

if [ "$SPARK_MODE" = "master" ]; then
    echo "Starting Spark Master..."
    "${SPARK_HOME}/sbin/start-master.sh"
    tail -F "${SPARK_HOME}/logs/"*
fi

if [ "${SPARK_MODE}" = "worker" ]; then

    echo "Starting Spark Worker connecting to $SPARK_MASTER_URL..."
    "${SPARK_HOME}/sbin/start-worker.sh" "${SPARK_MASTER_URL}"
    tail -F "${SPARK_HOME}/logs/"*
fi