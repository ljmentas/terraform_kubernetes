#!/bin/bash
terraform output kubeconfig > ~/.kube/kubeconfig
terraform output config-map-aws-auth > aws-auth.yaml
export KUBECONFIG=~/.kube/kubeconfig
kubectl apply -f aws-auth.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
kubectl apply -f eks-admin-service-account.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/metrics-server/v1.8.x.yaml
kubectl apply -f ./app_new.yaml
kubectl autoscale deployment my-nginx --cpu-percent=30 --min=1 --max=10





kubectl run my-nginx --image=ljmentas/backend:latest --requests=cpu=400m --expose --port=80
