# 在k8s上部署jenkins

## 1.创建服务

###1.1创建部署配置文件 jenkins-deployment.yaml 

内容
```

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins-admin
  namespace: default

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: jenkins-admin
  labels:
    k8s-app: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins-admin
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins
rules:
- apiGroups: ["", "extensions", "apps"]
  resources:
    - nodes
    - nodes/proxy
    - endpoints
    - secrets
    - pods
    - deployments
    - services
  verbs: ["get", "list", "watch"]
---

kind: Deployment
apiVersion: apps/v1beta2
metadata:
  name: jenkins
  namespace: default
  labels:
    k8s-app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: jenkins
  template:
    metadata:
      labels:
        k8s-app: jenkins
    spec:
      containers:
      - name: jenkins
        image: dengyc/jenkins
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        - containerPort: 50000
        volumeMounts:
        - name: jenkinshome
          mountPath: /var/jenkins_home
        - name: docker
          mountPath: /bin/docker
        - name: dockersock
          mountPath: /var/run/docker.sock    
      volumes:
      - name: jenkinshome
        nfs:
          server: 192.168.31.245
          path: "/kube_nfs_home/jenkins_home"
      - name: docker
        hostPath:
          path: "/usr/bin/docker"
      - name: dockersock
        hostPath:
          path: "/var/run/docker.sock"
      serviceAccount: "jenkins-admin"

---
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins
  namespace: default
  annotations:
    prometheus.io/scrape: 'true'
spec:
  ports:
    - port: 8080
      name: jenkins
      nodePort: 30001
      targetPort: 8080
    - port: 50000
      name: jenkins-agent
      nodePort: 50000
      targetPort: 50000
  type: NodePort
  selector:
    k8s-app: jenkins


```
执行创建命令
```
kubectl create -f jenkins-deployment.yaml   
```
检查
```
kubectl get pod  
```
输出
```
NAME                                READY     STATUS              RESTARTS   AGE  
jenkins-68c9cf9df9-82s8l            1/1       Running             0          4m  
```
等待状态变成Running后查看日志
```
kubectl logs jenkins-68c9cf9df9-82s8l 
``` 
输出（jenkins的日志输出）