#!/bin/sh
#
# Downloads the private SSL Key (used to sign authenticating requests from SSL clients)
# from S3.  Meant to be run at boot time.
#
# Usage: ./get-private-key.sh

PRIVATE_KEY_S3_URL=s3://choice-secrets/elasticsearch-logstash-kibana/log-courier.key
LOCAL_KEY_PATH=/etc/pki/tls/private/log-courier.key

aws s3 cp $PRIVATE_KEY_S3_URL $LOCAL_KEY_PATH
