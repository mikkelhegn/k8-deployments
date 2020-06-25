#!/bin/bash

# Generating a random strign for Resource Group and Cluster name if not provided
RNDSTR=aks-${RANDOM}
export RESOURCE_GROUP=${1:-$RNDSTR}
export CLUSTER_NAME=${1:-$RNDSTR}
export K8VERSION=${3:-0}

# Sets variables with deafults
LOCATION=${2:-westeurope}

# Getting latest patch of given minor version
if [ $K8VERSION == 0 ]
then
    MINOR_VERSION=1.16
    K8VERSION=$(az aks get-versions -l $LOCATION --query "orchestrators[?contains(orchestratorVersion,'$MINOR_VERSION')].orchestratorVersion | [-1]" --output tsv)
fi
echo "Using version $K8VERSION"

# Check if resource group exists, create or return from the script
echo "Creating resource group $RESOURCE_GROUP in $LOCATION..."
if [ $(az group exists --name $RESOURCE_GROUP -o tsv) == 'false' ]
then
    az group create -n $RESOURCE_GROUP -l $LOCATION --query properties.provisioningState
else
    echo  "Resource group $RESOURCE_GROUP already exists, reusing..."
fi

# Create the cluster
echo "Creating cluster $CLUSTER_NAME..."
az aks create -g $RESOURCE_GROUP --name $CLUSTER_NAME \
    --location $LOCATION --generate-ssh-keys \
    --enable-managed-identity --kubernetes-version $K8VERSION \
    --network-policy calico --network-plugin kubenet

echo "Getting credentials for $CLUSTER_NAME..."
az aks get-credentials -n $CLUSTER_NAME -g $RESOURCE_GROUP

echo "Setting context to $CLUSTER_NAME..."
kubectl config use-context $CLUSTER_NAME

echo 'Done!'