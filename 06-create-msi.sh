#!/bin/bash
source 00-setup.sh

az identity create --name $CLUSTER_NAME --resource-group $GROUP

set +e
while [ -z $IDENTITY_PRINCIPAL ]; do
   sleep 3
   IDENTITY_PRINCIPAL=$(az identity show --resource-group $GROUP --name $CLUSTER_NAME | jq -r .principalId)
done
set -e

# TODO: reduce the role power for this when we can figure it out
az role assignment create --role "Owner" --assignee $IDENTITY_PRINCIPAL --description "Grant $CLUSTER_NAME to everything in the $GROUP resource group"
