
kubectl create -f ./traefik-ingress/1.traefik-rbac.yaml
kubectl create -f ./traefik-ingress/2.traefik-deployment.yaml
kubectl create -f ./traefik-ingress/3.traefik-ds.yaml
kubectl create -f ./traefik-ingress/4.ui.yaml

kubectl create -f ./dashboard/admin-role.yaml
kubectl create -f ./dashboard/kubernetes-dashboard.yaml

kubectl create -f ./jenkins/jenkins-deployment.yaml
kubectl create -f ./registry/registry-deployment.yaml


