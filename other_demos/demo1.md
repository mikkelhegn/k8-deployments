# Demo 1 - ACR and ACI

## Create a container

cat dockerfile
docker build . -t helloparis
docker run --rm helloparis

## Create RG

az group create --name aciDemo --location westeurope

## Create ACR

az acr create --resource-group aciDemo --name helloparisacr --sku Basic --admin-enabled true

## Push container to ACR

az acr login --name helloparisacr
docker tag helloparis helloparisacr.azurecr.io/helloparis:v1001
docker push helloparisacr.azurecr.io/helloparis:v1001
az acr repository show --name helloparisacr --image helloparis:v1001

## Run container in ACI

### SP Setup
az acr show --name helloparisacr --query id --output tsv

az ad sp create-for-rbac --name http://helloparispullsp --scopes /subscriptions/c484c80e-0a6f-4470-86de-697ecee16984/resourceGroups/aciDemo/providers/Microsoft.ContainerRegistry/registries/helloparisacr --role acrpull

(az acr credential show -n helloparis)

az container create -g aciDemo -n helloparis --image helloparisacr.azurecr.io/helloparis:v1001 --cpu 1 --memory 1 --registry-login-server helloparisacr.azurecr.io --registry-username --registry-password 

az container attach --resource-group aciDemo --name helloparis

## Clean-up

az group delete --name aciDemo --no-wait
