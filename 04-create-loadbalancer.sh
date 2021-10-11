#!/bin/bash

source 00-setup.sh

# Create public ip
az network public-ip create \
  --resource-group $GROUP \
  --sku Standard \
  --name talos-cp \
  --allocation-method static

# Create lb
az network lb create \
  --resource-group $GROUP \
  --name talos-cp \
  --sku Standard \
  --public-ip-address talos-cp \
  --frontend-ip-name talos-cp \
  --backend-pool-name talos-cp

# Create health check
az network lb probe create \
  --resource-group $GROUP \
  --lb-name talos-cp \
  --name talos-lb-health \
  --protocol tcp \
  --port 6443

# Create lb rule for 6443
az network lb rule create \
  --resource-group $GROUP \
  --lb-name talos-cp \
  --name talos-6443 \
  --protocol tcp \
  --frontend-ip-name talos-cp \
  --frontend-port 6443 \
  --backend-pool-name talos-cp \
  --backend-port 6443 \
  --probe-name talos-lb-health

# Create lb rule for 50000
az network lb rule create \
  --resource-group $GROUP \
  --lb-name talos-cp \
  --name talos-api \
  --protocol tcp \
  --frontend-ip-name talos-cp \
  --frontend-port 50000 \
  --backend-pool-name talos-cp \
  --backend-port 50000 \
  --probe-name talos-lb-health
