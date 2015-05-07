#!/bin/bash
# Cassandra backup to S3
CASSBUCKET=loadtest-cassandra-archive
CLUSTERNAME=$(cat /etc/cassandra/conf/cassandra.yaml | grep cluster_name | cut -d' ' -f 2)
REGION=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${REGION:0:${#REGION}-1}
/usr/local/bin/chelydra backup --s3-bucket-region=$REGION --s3-ssenc --s3-bucket-name=$CASSBUCKET --s3-base-path=$CLUSTERNAME --new-snapshot --backup-schema
