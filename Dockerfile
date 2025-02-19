# Base Image
FROM ubuntu:22.04

# Install essential binaries
RUN apt-get update && \
    apt-get install -y wget vim bzip2 ca-certificates \ 
    curl git build-essential libssl-dev openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set conda directory
ENV CONDA_HOME=/opt/miniconda

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_HOME} && \
    rm /tmp/miniconda.sh

# Add conda to PATH
ENV PATH=${CONDA_HOME}/bin:$PATH

# Update conda and install Jupyter
RUN conda update -n base -c defaults conda -y
RUN conda install -y jupyter


# # Spark variables
ENV SPARK_VERSION=3.5.4
ENV HADOOP_VERSION=3
ENV SCALA_VERSION=2.13
ENV SPARK_HOME=/opt/spark
ENV PATH=${SPARK_HOME}/bin:${SPARK_HOME}/sbin:$PATH
# ENV SPARK_MASTER_URL="spark://spark-master:7077"
# ENV SPARK_MASTER_HOST spark-master
# ENV SPARK_MASTER_PORT 7077
# ENV PYSPARK_PYTHON python3


RUN wget --quiet "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${SCALA_VERSION}.tgz" -O /tmp/spark.tgz && \
    tar -xzf /tmp/spark.tgz -C ./opt && \
    rm /tmp/spark.tgz && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${SCALA_VERSION} ${SPARK_HOME}

# Expose ports:
#  - 7077: Spark master communication
#  - 8080: Spark master Web UI
#  - 8081: Spark worker Web UI (if applicable)
#  - 8888: Jupyter Notebook
EXPOSE 7077 8080 8081 8888

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use the entrypoint script as the default command
ENTRYPOINT ["/entrypoint.sh"]

# CMD ["bin/bash"]

