# Scale

## Pre-req

az aks enable-addons -g ... -n ... --addons virtual-node --subnet-name vn-subnet

## Demo starts here

## HPA

k apply -f hpa.yaml
k get deployment aci-helloworld-hpa -w
k top pod
k autoscale deployment aci-helloworld-hpa --cpu-percent=50 --min=1 --max=10
k get hpa

Wait and see it scale down to 1

## Cluster autoscaler

k describe nodes | grep -A 4 -E "Name: | Resource"
k apply -f ca.yaml
k get deployment aci-helloworld-ca
k get po
k describe pod/aci-helloworld-ca
k describe configmap/cluster-autoscaler-status -n kube-system

## Virtual Nodes scaling

k apply -f vn.yaml
k get pods

### Clean-up

k delete deployment/aci-helloworld
k delete deployment/aci-helloworld-ca
k delete deployment/aci-helloworld-hpa
k delete hpa/aci-helloworld-hpa
