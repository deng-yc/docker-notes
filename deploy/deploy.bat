
kubectl create -f ./kube-dashboard.yaml

kubectl create -f ./ingress.yaml

kubectl create -f ./mongodb.yaml

kubectl create -f ./docker-registry.yaml

kubectl create -f ./jenkins.yaml

kubectl create -f config.%1.yaml



