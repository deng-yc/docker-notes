
kubectl delete -f ./kube-dashboard.yaml

kubectl delete -f ./ingress.yaml

kubectl delete -f ./mongodb.yaml

kubectl delete -f ./docker-registry.yaml

kubectl delete -f ./jenkins.yaml

kubectl delete -f config.%1.yaml



