# Demo 1 - ACR and ACI

## Create a container

cat dockerfile
docker build . -t hellotechorama
docker run --rm hellotechorama

## Create RG

az group create --name aciDemo --location westeurope

## Create ACR

az acr create --resource-group aciDemo --name ... --sku Basic --admin-enabled true

## Push container to ACR

az acr login --name myaci
docker tag hellotechorama myaci.azurecr.io/hellotechorama:v1001
docker push myaci.azurecr.io/hellotechorama:v1001
az acr repository show --name myaci --image hellotechorama:v1001

## Run container in ACI

az acr credential show -n acimikhegn

az container create -g aciDemo -n hellotechorama --image myaci.azurecr.io/hellotechorama:v1001 --cpu 1 --memory 1 --registry-login-server myaci.azurecr.io --registry-username myaci --registry-password myaci

az container attach --resource-group aciDemo --name hellotechorama

## Clean-up

az group delete --name aciDemo
