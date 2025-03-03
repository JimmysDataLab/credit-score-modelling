# Base Image
FROM ubuntu:22.04

# make app directory
RUN mkdir app
COPY . /app


# Install essential binaries
RUN apt-get update \
    && apt-get install -y wget openjdk-11-jdk vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install conda and python environment
ENV PYTHON_VERSION=3.11.4
ENV CONDA_HOME=/opt/miniconda
ENV PATH=${CONDA_HOME}/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_HOME} && \
    rm /tmp/miniconda.sh
RUN conda init --all && \
    . ~/.bashrc && \
    conda update -n base -c defaults conda -y && \
    conda create --name spark_env python=${PYTHON_VERSION} && \
    conda activate spark_env && \
    pip install -r /app/requirements.txt 
ENV PYTHONPATH=/app


# Install Spark
ENV SPARK_VERSION=3.5.5
ENV SPARK_HOME=/opt/spark
ENV PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:$PATH
RUN wget --quiet "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}.tgz" -O /tmp/spark.tgz \
    && tar -xzf /tmp/spark.tgz -C /opt \
    && rm /tmp/spark.tgz \
    && mv /opt/spark-${SPARK_VERSION} ${SPARK_HOME}

# Install Hadoop
ENV HADOOP_VERSION=3.3.5
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PATH}

RUN wget --quiet "https://dlcdn.apache.org/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" -O /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /opt \
    && rm /tmp/hadoop.tar.gz \
    && mv /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME} 

# HDFS data paths hdfs://namenode:9000/data/train
ENV HADOOP_USER_NAME=root
ENV CORE_CONF_fs_defaultFS=hdfs://namenode:9000
#ENV HDFS_DIR=/tmp/hadoop-root/dfs
ENV TRAIN_PATH=/data/train
ENV TEST_PATH=/data/test


RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
