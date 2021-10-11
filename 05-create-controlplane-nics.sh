#!/bin/bash

source 00-setup.sh

# NB: Because the CCM manages its own load balancer and Azure has a limitation of one load balancer per NIC,
#  we have to configure the controlplane nodes with two NICs.
#  Somewhat weirdly, we bind the node public IPs to the primary interface because that is the only one which gets a default route...
#  but it is also the one the CCM chooses to use.
#  Thus, the "controlplane" NIC is strictly for the _kubernetes_ controlplane, NOT the Talos controlplane.

for i in $( seq 0 1 2 ); do
  # Create public IP for each nic
  az network public-ip create \
    --resource-group $GROUP \
    --sku Standard \
    --name talos-controlplane-public-ip-$i \
    --allocation-method static

  # Create primary nic
  az network nic create \
    --resource-group $GROUP \
    --name talos-controlplane-$i \
    --vnet-name talos-vnet \
    --subnet talos-subnet \
    --private-ip-address 10.0.0.1$i \
    --public-ip-address talos-controlplane-public-ip-$i\
    --network-security-group talos-sg

  # Bind controlplane node to our load balancer by IP to avoid interface contention with CCM LB.
  az network lb address-pool address add -g talos --lb-name talos-cp \
     --pool-name talos-cp -n talos-cp-$i --vnet talos-vnet \
     --ip-address 10.0.0.1$i

done
