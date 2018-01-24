# 配置nfs服务


## 1.安装nfs服务

```
sudo apt-get install nfs-kernel-server nfs-common portmap
```

## 2.配置portmap 两种方式任选一种
```
sudo vim /etc/default/portmap 去掉 -i 127.0.0.1
```
```
sudo dpkg-reconfigure portmap 选择"否"
```

## 3.配置共享目录

```
mkdir /kube_nfs_home
```

```
sudo vi /etc/exports
```
内容
```
/kube_nfs_home *(rw,sync,no_root_squash)
```
参数说明
```
/home   ：共享的目录
*       ：指定哪些用户可以访问
        *  所有可以ping同该主机的用户
        192.168.1.*  指定网段，在该网段中的用户可以挂载
        192.168.1.12 只有该用户能挂载
(ro,sync,no_root_squash)：  权限
        ro : 只读
        rw : 读写
        sync :  同步
        no_root_squash: 不降低root用户的权限
    其他选项man 5 exports 查看
```

## 4.重启nfs服务
```
sudo /etc/init.d/nfs-kernel-server restart
```

## 5.测试挂载
```
sudo mount 127.0.0.1:/kube_nfs_home /mnt
```


## 6.在每个节点上安装 nfs-common

```
sudo apt-get install -y nfs-common
```