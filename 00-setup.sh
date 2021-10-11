#!/bin/bash

set -e

# MUST BE SET
export SUBSCRIPTION_ID="c54c366b-XXXX-40eb-88ab-054eb9f343ae"

export STORAGE_ACCOUNT="talosscmtest"
export STORAGE_CONTAINER="images"
export GROUP="talos"
export LOCATION="eastus"
export CONNECTION=$(az storage account show-connection-string \
                    -n $STORAGE_ACCOUNT \
                    -g $GROUP \
                    -o tsv)

# CLUSTER_NAME is the arbitrary _local_ name for this cluster.
export CLUSTER_NAME="test-azure"

export WORKER_COUNT=1
