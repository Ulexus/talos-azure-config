#!/bin/bash

source 00-setup.sh

IDENTITY_PRINCIPAL=$(az identity show --resource-group $GROUP --name $CLUSTER_NAME | jq -r .principalId)
CLIENT_ID=$(az identity show --resource-group $GROUP --name $CLUSTER_NAME | jq -r .clientId)
TENANT_ID=$(az identity show --resource-group $GROUP --name $CLUSTER_NAME | jq -r .tenantId)

cat >azure.json <<ENDHERE
{
    "cloud":"AzurePublicCloud",
    "tenantId": "$TENANT_ID",
    "subscriptionId": "$SUBSCRIPTION_ID",
    "resourceGroup": "$GROUP",
    "location": "$LOCATION",
    "vnetName": "talos-vnet",
    "vnetResourceGroup": "$GROUP",
    "subnetName": "talos-subnet",
    "primaryAvailabilitySetName": "talos-controlplane-av-set",
    "loadBalancerSku": "standard",
    "routeTableName": "$CLUSTER_NAME",
    "routeTableResourceGroup": "$GROUP",
    "securityGroupName": "talos-sg",
    "securityGroupResourceGroup": "$GROUP",
    "userAssignedIdentityID": "$CLIENT_ID",
    "useManagedIdentityExtension": true,
    "useInstanceMetadata": false
}
ENDHERE

set +e
kubectl -n kube-system delete secret/azure-cloud-provider
set -e

kubectl -n kube-system create secret generic azure-cloud-provider --from-file=cloud-config=azure.json

kubectl create -f 21-cloud-controller-manager.yaml
kubectl create -f 22-cloud-node-manager.yaml
