#!/bin/bash

source 00-setup.sh

IDENTITY_ID=$(az identity show --resource-group $GROUP --name $CLUSTER_NAME | jq -r .id)

if [ "$IDENTITY_ID" == "" ]; then
   echo "Identity not found; did you create one?"
   exit 1
fi

az vm availability-set create \
  --name talos-controlplane-av-set \
  -g $GROUP

# Create the controlplane nodes
for i in $( seq 0 2 ); do
  az vm create \
    --name talos-controlplane-$i \
    --image talos \
    --custom-data ./controlplane.yaml \
    -g $GROUP \
    --admin-username talos \
    --generate-ssh-keys \
    --verbose \
    --boot-diagnostics-storage $STORAGE_ACCOUNT \
    --os-disk-size-gb 20 \
    --nics talos-controlplane-$i \
    --public-ip-sku Standard \
    --availability-set talos-controlplane-av-set \
    --assign-identity $IDENTITY_ID \
    --no-wait
done

# Create worker nodes
for i in $( seq 0 $[$WORKER_COUNT - 1] ); do
  az vm create \
    --name talos-worker-$i \
    --image talos \
    --vnet-name talos-vnet \
    --subnet talos-subnet \
    --custom-data ./worker.yaml \
    -g $GROUP \
    --admin-username talos \
    --generate-ssh-keys \
    --verbose \
    --boot-diagnostics-storage $STORAGE_ACCOUNT \
    --nsg talos-sg \
    --os-disk-size-gb 20 \
    --public-ip-sku Standard \
    --assign-identity $IDENTITY_ID \
    --no-wait
 done

# NOTES:
# `--admin-username` and `--generate-ssh-keys` are required by the az cli,
# but are not actually used by talos
# `--os-disk-size-gb` is the backing disk for Kubernetes and any workload containers
# `--boot-diagnostics-storage` is to enable console output which may be necessary
# for troubleshooting
