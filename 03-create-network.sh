#!/bin/bash

source 00-setup.sh

# Create vnet
az network vnet create \
  --resource-group $GROUP \
  --location $LOCATION \
  --name talos-vnet \
  --subnet-name talos-subnet

# Create route-table (required by CCM)
az network route-table create -g $GROUP -n $CLUSTER_NAME

# Create network security group
az network nsg create -g $GROUP -n talos-sg

# Client -> apid
az network nsg rule create \
  -g $GROUP \
  --nsg-name talos-sg \
  -n apid \
  --priority 1001 \
  --destination-port-ranges 50000 \
  --direction inbound

# Trustd
az network nsg rule create \
  -g $GROUP \
  --nsg-name talos-sg \
  -n trustd \
  --priority 1002 \
  --destination-port-ranges 50001 \
  --direction inbound

# etcd
az network nsg rule create \
  -g $GROUP \
  --nsg-name talos-sg \
  -n etcd \
  --priority 1003 \
  --destination-port-ranges 2379-2380 \
  --direction inbound

# Kubernetes API Server
az network nsg rule create \
  -g $GROUP \
  --nsg-name talos-sg \
  -n kube \
  --priority 1004 \
  --destination-port-ranges 6443 \
  --direction inbound
