# 部署管理界面

## 1.下载官方的部署文件

```
wget https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```

## 2.修改配置文件

在service节点添加 type: NodePort

```
...
# ------------------- Dashboard Service ------------------- #

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30000
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
```

`注意: nodePort的范围只能是30000-32767,这个值在API server的配置文件中，用--service-node-port-range定义。`
`可在 /etc/kubernetes/manifests/kube-apiserver.yaml 中的command中添加一下内容`
```
- --service-node-port-range=80-65535
```
获取dashboard的外网访问端口：

```
kubectl -n kube-system get svc kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.103.137.160   <none>        443:30000/TCP   19m
```
然后就可以在浏览器使用集群中任意节点 30000 端口访问dashboard了,kube-proxy会自动将流量以round-robin的方式转发给该service的每一个pod。

`
注意：使用https协议访问
`

参考: [从外部访问Kubernetes中的Pod](https://jimmysong.io/kubernetes-handbook/guide/accessing-kubernetes-pods-from-outside-of-the-cluster.html)

## 3.生成dashboard登录token

创建 admin-role.yaml
```
vi admin-role.yaml
```
内容
```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```

执行
```
kubectl create -f admin-role.yaml
```
创建完成后获取secret和token的值。
```
# 获取admin-token的secret名字
$ kubectl -n kube-system get secret|grep admin-token
admin-token-sddms                           kubernetes.io/service-account-token   3         6m
# 获取token的值
$ kubectl -n kube-system describe secret admin-token-sddms 
Name:        admin-token-sddms 
Namespace:    kube-system
Labels:        <none>
Annotations:    kubernetes.io/service-account.name=admin
        kubernetes.io/service-account.uid=f37bd044-bfb3-11e7-87c0-f4e9d49f8ed0

Type:    kubernetes.io/service-account-token

Data
====
ca.crt:       1025 bytes
namespace:    11 bytes
token:        非常长的字符串
```

使用这个token登录dashboard

参考: [Kubernetes 中的认证](https://kubernetes.io/docs/admin/authentication/)



```
kubectl create secret tls ingress-secret --key cert/ingress-key.pem --cert cert/ingress.pem
```