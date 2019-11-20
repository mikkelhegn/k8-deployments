# IIS-Nginx-LetsEncrypt

This is a fun demo to setup an IIS server in a Windows container, exposed through Nginx and secured with Let's Encrypt certificates, using cert-manager.

## Install Helm in the cluster (using "old" Helm)

    1. `kubectl apply -f helm-rbac.yaml`
    1. `helm init --service-account=tiller`
    1. `helm repo update`

## Install Nginx ingress controller using Helm

1. `helm install stable/nginx-ingress`

## Install app and expose through ingress controller

1. `kubectl apply -f iis-svc-ingress.yaml`

## Test app over http

1. `kubectl get svc` - to get exposed IP
1. Test in browser...

## Set up cert-manager

1. Install the CustomResourceDefinition resources separately
    - `kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml`
1. Create the namespace for cert-manager
    - `kubectl create namespace cert-manager`
1. Label the cert-manager namespace to disable resource validation
    - `kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true`
1. Add the Jetstack Helm repository
    - `helm repo add jetstack https://charts.jetstack.io`
1. Update your local Helm chart repository cache
    - `helm repo update`
1. Install the cert-manager Helm chart
    - `helm install --name cert-manager --namespace cert-manager --version v0.10.1 jetstack/cert-manager`
1. Verify install
    - `kubectl get pods --namespace cert-manager`
    - `kubectl apply -f test-cert.yaml`
    - `kubectl describe certificate -n cert-manager-test`
    - `kubectl delete -f test-cert.yaml`

## set up Let's encrypt issuer

1. Change the e-mail in staging-issuer.yaml
1. `kubectl apply -f staging-issuer.yaml`

## Update the iis-ingress to use tls

1. Change the host name (twice) in the tls-ingress.yaml file for the ingress endpoint
1. `kubectl apply -f tls-ingress.yaml`
