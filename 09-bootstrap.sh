#!/bin/bash

source 00-setup.sh

export CONTROL_PLANE_0_IP=$(az network public-ip show \
                    --resource-group $GROUP \
                    --name talos-controlplane-public-ip-0 \
                    --query [ipAddress] \
                    --output tsv)
export CONTROL_PLANE_1_IP=$(az network public-ip show \
                    --resource-group $GROUP \
                    --name talos-controlplane-public-ip-1 \
                    --query [ipAddress] \
                    --output tsv)
export CONTROL_PLANE_2_IP=$(az network public-ip show \
                    --resource-group $GROUP \
                    --name talos-controlplane-public-ip-2 \
                    --query [ipAddress] \
                    --output tsv)

talosctl --talosconfig talosconfig config endpoints ${CONTROL_PLANE_0_IP} ${CONTROL_PLANE_1_IP} ${CONTROL_PLANE_2_IP}
talosctl --talosconfig talosconfig config nodes $CONTROL_PLANE_0_IP

NODE_UP=0
echo "waiting for node to come up..."

set +e
while [ $NODE_UP -eq 0 ]; do
   talosctl --talosconfig talosconfig version 2>&1 1>/dev/null

   if [ $? -eq 0 ]; then
      NODE_UP=1
   else
      sleep 5
   fi
done
set -e

echo "node up; bootstrapping..."

talosctl --talosconfig talosconfig bootstrap

echo "done"
