#!/bin/bash
set -e

## This path is set in the Dockerfile and hdfs-site.xml
## Checks the namenode directory for a VERSION file
## If not found, formats the namenode
# if [ ! -f ${NAMENODE_DIR}/current/VERSION ]; then
#     echo "Formatting NameNode since metadata is missing..."
#     hadoop namenode -format -force
#     echo "Making namenode directory..."
#     mkdir -p ${NAMENODE_DIR}
# else
#     echo "NameNode already formatted. Skipping format."
# fi

exec hadoop datanode
