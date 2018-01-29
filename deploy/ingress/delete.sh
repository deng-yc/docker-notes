kubectl delete -f 1.namespace.yaml
kubectl delete -f 2.default-backend.yaml
kubectl delete -f 3.configmap.yaml
kubectl delete -f 4.tcp-services-configmap.yaml
kubectl delete -f 5.udp-services-configmap.yaml
kubectl delete -f 6.1.rbac.yaml
kubectl delete -f 6.2.with-rbac.yaml