# 安装docker

确保kubelet使用的cgroup驱动程序与docker使用的驱动程序相同。

为了确保兼容性，您可以更新docker，如下所示：
```
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

k8s 目前最高支持17.03版本的docker
```
apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"

apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
```

# 安装 kubeadm, kubelet 和 kubectl

需要在所有机器上安装以上3个软件

```
apt-get update && apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update

apt-get install -y kubelet kubeadm kubectl
```


# 配置master机器

使用kubeadm初始化
```
kubeadm init --pod-network-cidr=10.244.0.0/16
```
`
注意:--pod-network-cidr=10.244.0.0/16 是后面安装pod网络必须参数()
`

如果开启swap了，需要禁用，不然无法启动
```
swapoff -a
```
开机禁用swap 
```
vi /etc/fstab
```
注释swap的代码

执行初始化后,得到一下输出内容
```
[init] Using Kubernetes version: v1.9.1
[init] Using Authorization modes: [Node RBAC]
[preflight] Running pre-flight checks.
	[WARNING FileExisting-crictl]: crictl not found in system path
[preflight] Starting the kubelet service
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [docker4 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.109.154]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated sa key and public key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "scheduler.conf"
[controlplane] Wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] Wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] Wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] Waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests".
[init] This might take a minute or longer if the control plane images have to be pulled.
[apiclient] All control plane components are healthy after 40.519915 seconds
[uploadconfig] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[markmaster] Will mark node docker4 as master by adding a label and a taint
[markmaster] Master docker4 tainted and labelled with key/value: node-role.kubernetes.io/master=""
[bootstraptoken] Using token: 5fad34.d525c5d91c17e82e
[bootstraptoken] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: kube-dns
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token 5fad34.d525c5d91c17e82e 192.168.109.154:6443 --discovery-token-ca-cert-hash sha256:e63060dc1757f8636214be2b720679e001866d825d1b30e3f5e147bc52f8882f

```
`子节点使用上面的代码加入集群`

配置 kubectl 在非root用户上使用
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
``` 
或者root账号执行
```
export KUBECONFIG=/etc/kubernetes/admin.conf
```

稍等一会获取节点
```
kubectl get nodes
```
输出
```
NAME      STATUS     ROLES     AGE       VERSION
docker4   NotReady   master    2m        v1.9.1
```
状态是NotReady

查看pods的状态
```
kubectl get pods --all-namespaces
```
输出
```
NAMESPACE     NAME                              READY     STATUS    RESTARTS   AGE
kube-system   etcd-docker4                      1/1       Running   0          2m
kube-system   kube-apiserver-docker4            1/1       Running   0          3m
kube-system   kube-controller-manager-docker4   1/1       Running   0          3m
kube-system   kube-dns-6f4fd4bdf-zp45r          0/3       Pending   0          3m
kube-system   kube-proxy-fz2fj                  1/1       Running   0          3m
kube-system   kube-scheduler-docker4            1/1       Running   0          3m
```
发现kube-dns还在挂起，需要安装Pod网络
# 安装Pod网络

安装Flannel网络
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```

稍等一会再次查看pods的状态,直到状态全部变为Running,再次查看节点状态，已经变成Ready了


# 添加节点到master

执行master节点init输出的结果
```
kubeadm join --token 5fad34.d525c5d91c17e82e 192.168.109.154:6443 --discovery-token-ca-cert-hash sha256:e63060dc1757f8636214be2b720679e001866d825d1b30e3f5e147bc52f8882f
```


集群搭建完成



