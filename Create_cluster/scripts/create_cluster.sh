#!/bin/bash

# Generating a random strign for Resource Group and Cluster name if not provided
RNDSTR=aks-${RANDOM}
export RESOURCE_GROUP=${1:-$RNDSTR}
export CLUSTER_NAME=${1:-$RNDSTR}

# Sets variables with deafults
LOCATION=${2:-EastUS}

# Generate a random password for the Windows nodes
# This doesn't work on mac -> https://unix.stackexchange.com/questions/45404/why-cant-tr-read-from-dev-urandom-on-osx
# PASSWORD_WIN=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)'!@#$%'
# PASSWORD_WIN="P@SSw0rd!@#$%"

# Setting Windows nodepool name
WIN_POOL_NAME=winp1

# Getting latest patch of given minor version
MINOR_VERSION=1.15
LATEST_PATCH_VER=$(az aks get-versions -l $LOCATION --query "orchestrators[?contains(orchestratorVersion,'$MINOR_VERSION')].orchestratorVersion | [-1]" --output tsv)

# Check if resource group exists, create or return from the script
echo "Creating resource group $RESOURCE_GROUP in $LOCATION..."
if [ $(az group exists --name $RESOURCE_GROUP -o tsv) == 'false' ]
then
    az group create -n $RESOURCE_GROUP -l $LOCATION --query properties.provisioningState
else
    echo  "Resource group $RESOURCE_GROUP already exists, reusing..."
fi

# Create the cluster
# --windows-admin-password and --windows-admin-username is the local admin for the Windows worker nodes
# --generate-ssh-keys generates random ssh keys for SSH access
# --node-count is for the default Linux node pool
# --enable-vmss enables multiple node pools
# --network-plugin azure specifies to use Azure CNI, which is the only supported network plugin for Windows clusters
echo "Creating cluster $CLUSTER_NAME..."
az aks create -g $RESOURCE_GROUP --name $CLUSTER_NAME
    --location $LOCATION --generate-ssh-keys
    --enable-managed-identity
    --network-plugin azure
    --kubernetes-version $LATEST_PATCH_VER 
    --node-count 2 --node-vm-size Standard_D2_v3
    --enable-cluster-autoscaler --min-count 2 --max-count 3
    --query properties.provisioningState

# Adding a Windows nodepool to the cluster
# --os-type Windows to indicate the OS type for the node pool (linux or windows)
# --node-count 3 --node-vm-size Standard_D3_v2 nu,ber of nodes and SKU for the node pool
echo "Adding Windows node pool $WIN_POOL_NAME..."
az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME \
    --os-type Windows --name $WIN_POOL_NAME --node-count 3 \
    --node-vm-size Standard_D2s_v3 --kubernetes-version $LATEST_PATCH_VER \
    --query properties.provisioningState

echo "Getting credentials for $CLUSTER_NAME..."
az aks get-credentials -n $CLUSTER_NAME -g $RESOURCE_GROUP

echo "Setting context to $CLUSTER_NAME..."
kubectl config use-context $CLUSTER_NAME

echo -e "\e[0mAdding taints..."
kubectl get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' \
    | xargs -I XX k taint nodes XX windows=true:NoSchedule

echo 'Done!'