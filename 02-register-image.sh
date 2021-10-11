#!/bin/bash

source 00-setup.sh

az image create \
  --name talos \
  --source https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}/talos.vhd \
  --os-type linux \
  -g $GROUP
