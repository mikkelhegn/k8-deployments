#!/bin/bash

# Generating a random string for Resource Group and Cluster name if not provided
RNDSTR=aks-${RANDOM}

# Sets variables with defaults
RESOURCE_GROUP=$RNDSTR
CLUSTER_NAME=$RNDSTR
LOCATION='westeurope'
MINOR_VERSION='1.21'
ACRNAME='mikhegn'

while [[ $# -gt 0 ]]; do
    case "$1" in
        -rg )
            RESOURCE_GROUP="$2"; shift 2 ;;
        -n )
            CLUSTER_NAME="$2"; shift 2 ;;
        -l )
            LOCATION="$2"; shift 2 ;;
        -v )
            MINOR_VERSION="$2"; shift 2 ;;
        -acr )
            ACRNAME=$2; shift 2 ;;
        -h | --help )
            usage; exit 2 ;;
        *)
            echo "Unknown option '${1}'"; echo ""; usage; exit 3 ;;
    esac
done

echo "Using the following input:
-----
Resource Group: $RESOURCE_GROUP
Cluster Name: $CLUSTER_NAME
Location: $LOCATION
Kubernetes Minor Version: $MINOR_VERSION
ACR Name: $ACRNAME
-----"

# Getting latest patch of given minor version
echo "Finding the latest patch version for $MINOR_VERSION..."
K8VERSION=$(az aks get-versions -l $LOCATION --query "orchestrators[?contains(orchestratorVersion,'$MINOR_VERSION')].orchestratorVersion | [-1]" --output tsv)
echo "Will be using this patch version $K8VERSION"

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
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --location $LOCATION \
    --kubernetes-version $K8VERSION \
    --attach-acr $ACRNAME \
    --generate-ssh-keys \

echo "Getting credentials for $CLUSTER_NAME..."
az aks get-credentials -n $CLUSTER_NAME -g $RESOURCE_GROUP

echo "Getting kubectl version matching the cluster"
sudo az aks install-cli --client-version $K8VERSION

echo "Setting context to $CLUSTER_NAME..."
kubectl config use-context $CLUSTER_NAME

echo 'Done!'