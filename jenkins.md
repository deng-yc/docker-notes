# 在k8s上部署jenkins

## 1.创建服务

###1.1创建部署配置文件 jenkins-deployment.yaml 

内容
```
apiVersion: extensions/v1beta1  
kind: Deployment  
metadata:  
  name: jenkins  
spec:  
  replicas: 1  
  strategy:  
    type: RollingUpdate  
    rollingUpdate:  
      maxSurge: 2  
      maxUnavailable: 0  
  template:  
    metadata:  
      labels:  
        app: jenkins  
    spec:  
      containers:  
      - name: jenkins  
        image: dengyc/jenkins:latest  
        imagePullPolicy: IfNotPresent  
        ports:  
        - containerPort: 8080  
          name: web  
          protocol: TCP  
        - containerPort: 50000  
          name: agent  
          protocol: TCP  
        volumeMounts:  
        - name: jenkinshome  
          mountPath: /var/jenkins_home  
        env:  
        - name: JAVA_OPTS  
          value: "-Duser.timezone=Asia/Shanghai"  
      volumes:  
      - name: jenkinshome  
        nfs:  
          server: 192.168.31.245
          path: "/kube_nfs_home/jenkins_home" 

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