# 在k8s上部署jenkins

## 1.创建服务

###1.1创建部署配置文件 jenkins-deployment.yaml 

内容
```
#-------------Jenkins ServiceAccount 授权jenkins访问集群的账号--------------#
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: jenkins
  name: jenkins-admin
  namespace: default
---
#-------------Jenkins ClusterRoleBinding 授权jenkins访问集群的账号角色和权限--------------#
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
#-------------Jenkins Deployment 部署jenkins配置--------------#
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
#-------------Jenkins Service 部署jenkins服务--------------#

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

配置jenkins

## 配置kubernetes自动构建任务

### 1.安装插件

打开[系统管理]->[插件管理]

找到 Kubernetes plugin 插件，点击安装并重启

### 2.配置Kubernetes

打开[系统管理]->[系统设置]->[新增一个云] (最底部)-> Kubernetes

表单填写内容：

Name：自定义,比如:kubernetes

Kubernetes URL: Kubernetes apiserver 的地址加端口 比如:192.168.31.240:6443

Kubernetes server certificate key:

Kubernetes Namespace: 部署的命名空间 一般写default就可以

Jenkins URL: jenkins的master节点地址,这里最好填写集群中的内网地址  比如 http://jenkins:8080

其他字段默认即可

点击 [Add Pod Template] 按钮

填写表单

`Name: jnlp-salve`

Namespace: default

labels: jnlp-salve

其他字段默认

点击 [Add Container] 按钮

填写表单

`Name: jnlp` 

Docker Image: jenkinsci/jnlp-slave

Working directory: /home/jenkins

Command to run:   清空

Arguments to pass to the command: 清空

点击保存


### 3.使用

在创建自由风格任务的时候勾选

Restrict where this project can be run

Label Expression 中填写jnlp-slave (pod 模板名称)


当构建的时候就会自动在集群中创建一个Pod，构建完成后Pod会被删除