#!/bin/bash
source 00-setup.sh

if [ ! -e disk.vhd ]; then
   echo "First, download and extract the Azure image for the latest Talos release from:"
   echo "  https://github.com/talos-systems/talos/releases"
   echo
   exit 1
fi

az storage blob upload \
  --connection-string $CONNECTION \
  --container-name $STORAGE_CONTAINER \
  -f disk.vhd \
  -n talos.vhd
