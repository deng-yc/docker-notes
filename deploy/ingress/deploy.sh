kubectl create -f 1.namespace.yaml
kubectl create -f 2.default-backend.yaml
kubectl create -f 3.configmap.yaml
kubectl create -f 4.tcp-services-configmap.yaml
kubectl create -f 5.udp-services-configmap.yaml
kubectl create -f 6.1.rbac.yaml
kubectl create -f 6.2.with-rbac.yaml