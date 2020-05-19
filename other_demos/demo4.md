# Install Helm

## Install traefik

helm install traefik --namespace kube-system stable/traefik --values traefik-config.yaml

### Get ip

helm status traefik-release

### hosts

sudo vi /etc/hosts
--> Domain: iis.on.windows.in.containers.on.kubernetes.awesome

40.118.162.146

## Deploy ASP.NET app

k apply -f iis.yaml
k get po -o wide

## Clean-up

k delete svc,deployment,ingress -l app=iis
helm del --purge traefik-release
