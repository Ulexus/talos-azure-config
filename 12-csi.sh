#!/bin/bash

source 00-setup.sh

if [ "$(which helm)" == "" ]; then
   echo "Please install 'helm' to install the Azure CSI driver"
   exit 1
fi

#kubectl apply -f azure-configmap.yaml

helm repo add azuredisk-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts
helm install azuredisk-csi-driver azuredisk-csi-driver/azuredisk-csi-driver --namespace kube-system

kubectl apply -f storageclass-csi.yaml
