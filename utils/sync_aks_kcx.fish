#!/usr/bin/env fish

set addCount 0
set removeCount 0

# default will preserve cluster connections in kube.config
argparse --name=reset 'r/reset' -- $argv

# Get clusters
set aksClusters (az aks list -o json | jq '.[] | "\(.name);\(.resourceGroup)"')
echo 'I: Found '(count $aksClusters)' clusters in Azure'
set kubectxClusters (kubectx)

# Resetting kube.config
if set -q _flag_reset
    echo 'I: Resetting kube.config connections'
    for clusterConfig in $kubectxClusters
        kubectx -d $clusterConfig
        echo 'I: removed cluster: '$clusterConfig
        set removeCount (math $removeCount + 1)
    end
end

# Check if cluster is in kube.config, otherwise add it
for aksCluster in $aksClusters
    set curCluster (string unescape $aksCluster | string split ";")
    # If we did reset, just add the clsuter
    if set -q _flag_reset
        az aks get-credentials -n $curCluster[1] -g $curCluster[2]
        echo 'I: Added cluster: '$curCluster[1]
        set addCount (math $addCount + 1)
    else
        if not contains $curCluster[1] $kubectxClusters
            az aks get-credentials -n $curCluster[1] -g $curCluster[2]
            echo 'I: Added cluster: '$curCluster[1]
            set addCount (math $addCount + 1)
        else
            echo 'I: Cluster: '$curCluster[1]' already exists in kube.config'
        end
    end
end

echo 'I: Added '$addCount' clusters to kube.config'
echo 'I: Removed '$removeCount' clusters from kube.config'