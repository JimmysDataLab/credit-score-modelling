#!/bin/bash
set -e

source "${CONDA_HOME}/bin/activate" spark_env

stage_data() {
    echo "Checking and staging data..."
    python /app/scripts/stage_data.py
}

init_hdfs_dirs() {
    echo "Checking training and testing directories"

    # Wait for HDFS to be available
    until hdfs dfs -test -d / ; do
        echo "Waiting for HDFS to be available..."
        sleep 5
    done

    if ! hdfs dfs -test -d "${TRAIN_PATH}"; then
        echo "Training directory does not exist... Creating"
        hdfs dfs -mkdir -p "${TRAIN_PATH}"
        hdfs dfs -chmod 777 "${TRAIN_PATH}"
    fi

    if ! hdfs dfs -test -d "${TEST_PATH}"; then
        echo "Testing directory does not exist... Creating"
        hdfs dfs -mkdir -p "${TEST_PATH}"
        hdfs dfs -chmod 777 "${TEST_PATH}"
    fi
}

if [ "$HADOOP_MODE" = "namenode" ]; then
    if [ ! -f "${HDFS_DIR}/name/current/VERSION" ]; then
        echo "Namenode is empty.. Formatting.."
        hdfs namenode -format
    fi
    exec hdfs namenode


elif [ "$HADOOP_MODE" = "datanode" ]; then
    exec hdfs datanode


elif [ "$SPARK_MODE" = "master" ]; then
    echo "Starting Spark Master..."
    "$SPARK_HOME/sbin/start-master.sh"
    tail -F "$SPARK_HOME/logs/"*

elif [ "$SPARK_MODE" = "worker" ]; then
    if [ -z "$SPARK_MASTER_URL" ]; then
        echo "Error: SPARK_MASTER_URL is not set for worker mode."
        exit 1
    fi
    echo "Starting Spark Worker connecting to $SPARK_MASTER_URL..."
    "$SPARK_HOME/sbin/start-worker.sh" "$SPARK_MASTER_URL"
    tail -F "$SPARK_HOME/logs/"*

elif [ "$JUPYTER_ENABLE" = "enable" ]; then
    stage_data
    echo "Starting Jupyter Notebook..."
    exec jupyter notebook \
      --ip=0.0.0.0 \
      --port=8888 \
      --no-browser \
      --allow-root
else
    exec /bin/bash
fi
