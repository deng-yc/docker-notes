

kubectl delete -f ./dashboard/admin-role.yaml
kubectl delete -f ./dashboard/kubernetes-dashboard.yaml

kubectl delete -f ./jenkins/jenkins-deployment.yaml
kubectl delete -f ./registry/registry-deployment.yaml


kubectl delete -f ./traefik-ingress/1.traefik-rbac.yaml
kubectl delete -f ./traefik-ingress/2.traefik-deployment.yaml
kubectl delete -f ./traefik-ingress/3.traefik-ds.yaml
kubectl delete -f ./traefik-ingress/4.ui.yaml
