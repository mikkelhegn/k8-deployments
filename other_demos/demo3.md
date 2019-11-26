# Scale

## Pre-req

### Create Cluster

./create_cluster.sh cntourdemo westeurope

### Enable VK

k apply -f tillerrbac.yaml
helm init --service-account tiller

az aks install-connector -g cntourdemo -n cntourdemo --connector-name virtual-kubelet --os-type Both

## Demo starts here

## HPA

k apply -f hpa.yaml
k autoscale deployment aci-helloworld-hpa --cpu-percent=50 --min=1 --max=10
k get hpa

takes a while...

## Cluster autoscaler

k describe nodes | grep -A 4 -E "Name: | Resource"
k apply -f ca.yaml
k get deployment aci-helloworld-ca
k describe nodes | grep -A 4 -E "Name: | Resource"
k get pods
k describe pod/aci-helloworld-ca-
k describe configmap/cluster-autoscaler-status -n kube-system

## Virtual Nodes scaling

k apply -f vn.yaml
k get pods

### Clean-up

k delete deployment/aci-helloworld
k delete deployment/aci-helloworld-ca
k delete deployment/aci-helloworld-hpa
k delete hpa/aci-helloworld-hpa
