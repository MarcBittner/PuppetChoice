#!/bin/bash

#
# This script gets included on each cassandra box and
# is responsible for deploying the appropriate cql file
# when we are bootstrapping a DB instance from
# the cassandra base image.
#

CQL=$1

# run the cql
