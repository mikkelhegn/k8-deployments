#!/bin/bash

helm upgrade nginx-ic stable/nginx-ingress --set controller.service.annotations."service\.beta\.kubernetes\.io\/azure-load-balancer\-internal"\=true