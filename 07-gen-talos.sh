#!/bin/bash

source 00-setup.sh

LB_PUBLIC_IP=$(az network public-ip show \
              --resource-group $GROUP \
              --name talos-cp \
              --query [ipAddress] \
              --output tsv)

CONTROL_PLANE_0_IP=$(az network public-ip show \
              --resource-group $GROUP \
              --name talos-controlplane-public-ip-0 \
              --query [ipAddress] \
              --output tsv)
CONTROL_PLANE_1_IP=$(az network public-ip show \
              --resource-group $GROUP \
              --name talos-controlplane-public-ip-1 \
              --query [ipAddress] \
              --output tsv)
CONTROL_PLANE_2_IP=$(az network public-ip show \
              --resource-group $GROUP \
              --name talos-controlplane-public-ip-2 \
              --query [ipAddress] \
              --output tsv)


talosctl gen config $CLUSTER_NAME \
   https://${LB_PUBLIC_IP}:6443 \
   --config-patch-control-plane "$(jq -c . config-patch-controlplane.json)"
