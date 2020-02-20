#!/bin/bash

# Generating a random strign for Resource Group and Cluster name if not provided
RNDSTR=aks-${RANDOM}
export RESOURCE_GROUP=${1:-$RNDSTR}
export CLUSTER_NAME=${1:-$RNDSTR}

# Sets variables with deafults
LOCATION=${2:-EastUS}

# Generate a random password for the Windows nodes
PASSWORD_WIN=$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c 20)'!@#$%'

# Setting Windows nodepool name
WIN_POOL_NAME=winp1

# Getting latest 1.14 K8 version
LATEST_PATCH_VER=$(az aks get-versions -l $LOCATION --query "orchestrators[?contains(orchestratorVersion,'1.14')].orchestratorVersion | [-1]" --output tsv)

# Check if resource group exists, create or return from the script
echo -e "\e[0mCreating resource group \e[1;32m$RESOURCE_GROUP \e[0min \e[1;32m$LOCATION...\e[0m"
if [ $(az group exists --name $RESOURCE_GROUP -o tsv) == 'false' ]
then
    az group create -n $RESOURCE_GROUP -l $LOCATION --query properties.provisioningState
else
    echo -e "\e[1;31mResource group $RESOURCE_GROUP already exists.\e[0m"
    echo -e "\n\e[0mPlease try again using with a new name!\e[0m\n"
    return
fi

# Create the cluster
echo -e "\n\e[0mCreating cluster \e[1;32m$CLUSTER_NAME...\e[0m"
az aks create -g $RESOURCE_GROUP --name $CLUSTER_NAME  --windows-admin-password $PASSWORD_WIN --windows-admin-username azureuser --location $LOCATION --generate-ssh-keys --node-count 2 --enable-vmss --network-plugin azure --kubernetes-version $LATEST_PATCH_VER --node-vm-size Standard_D2_v3 --query properties.provisioningState

# Adding a Windows nodepool to the cluster
echo -e "\e[0mAdding Windows node pool \e[1;32m$WIN_POOL_NAME..."
az aks nodepool add -g $RESOURCE_GROUP --cluster-name $CLUSTER_NAME --os-type Windows --name $WIN_POOL_NAME --node-count 3 --node-vm-size Standard_D2s_v3 --kubernetes-version $LATEST_PATCH_VER --query properties.provisioningState

echo -e "\e[0mGetting credentials for \e[1;32m$CLUSTER_NAME..."
az aks get-credentials -n $CLUSTER_NAME -g $RESOURCE_GROUP

echo -e "\e[0mSetting context to \e[1;32m$CLUSTER_NAME..."
k config use-context $CLUSTER_NAME

echo -e "\e[0mAdding taints..."
k get nodes -l beta.kubernetes.io/os=windows -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I XX k taint nodes XX windows=true:NoSchedule

echo -e '\e[1;32mDone!\e[0'