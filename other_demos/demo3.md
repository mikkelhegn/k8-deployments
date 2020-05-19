# Scale

## Pre-req

az aks enable-addons -g ... -n ... --addons virtual-node --subnet-name vn-subnet

### Enable VN

az network vnet subnet create -g myResourceGroup --vnet-name myVnet --name myVirtualNodeSubnet --address-prefixes 10.241.0.0/16 --delegations Microsoft.ContainerInstance/containerGroups
az aks enable-addons -g myResourceGroup -n myAKSCluster --addons virtual-node --subnet-name myVirtualNodeSubnet

### Enable Cluster Autoscaler
az aks nodepool update -g fasttrack-demo --cluster-name fasttrack-demo -n nodepool1 --enable-cluster-autoscaler --min-count 2 --max-count 5

## Demo starts here

## HPA

k apply -f hpa.yaml
k get deployment aci-helloworld-hpa -w
k top pod
k autoscale deployment aci-helloworld-hpa --cpu-percent=50 --min=1 --max=10
k get hpa

Wait and see it scale down to 1

## Cluster autoscaler

k describe configmap/cluster-autoscaler-status -n kube-system
k apply -f ca.yaml
k get deployment aci-helloworld-ca
k get po
k describe pod/aci-helloworld-ca
k describe configmap/cluster-autoscaler-status -n kube-system

## Virtual Nodes deployment

k apply -f vn.yaml
k get pods

### Clean-up

k delete deployment/aci-helloworld-ca
k delete deployment/aci-helloworld-hpa
k delete hpa/helloparis-autoscaler
