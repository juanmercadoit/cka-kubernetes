# Documentation

## Prerequisites

- Kubernetes Cluster Installed.
- A user which have an admin role usually to admin the kubernetes cluster.

## NFS Service

You could try some docker image or install the service in a VM or locally.

### Docker Image.

### Install the service.

```
$ sudo apt update
$ sudo apt install nfs-kernel-server -y
```

### Creating the necessary folders to sharing it using nfs.

```
$ sudo mkdir /nfs-data
$ sudo chown -R nobody:nogroup /nfs-data
$ sudo chmod 2770 /nfs-data
```

### Add entries in the /etc/exports file.

```
/nfs-data *(rw,sync,fsid=0,no_root_squash,crossmnt,no_subtree_check,no_acl,insecure)
```

- the star represents all ranges of ip that could access to the service. But if you need only access some range as 192.168.0.0/24 , only replace the star with this value.

### To the changes be apply, you need to do some steps:

```
$ sudo exportfs -a
$ sudo systemctl restart nfs-kernel-server
$ sudo systemctl status nfs-kernel-server
```

## Worker Nodes

```
$ sudo apt install nfs-common -y
```

### Config the nfs client

When you start with configuration agent, need keep in mind the ip address or DNS name of the server  where the NFS server is running the service.
In the following command I replace for the tag IP_NFS_ADDR.
```
 sudo apt install nfs-client -y
 sudo mkdir /nfs
 sudo chmod 0750 /nfs
 sudo echo "IP_NFS_ADDR:/nfs-data /nfs nfs rsize=8192,wsize=8192,timeo=14,intr" >> /etc/fstab
 sudo mount -t nfs -v IP_NFS_ADDR:/nfs-data /nfs
```

## Install the Kubernetes NFS provisioner

### Deploy the provisioner

- My recommendation for mantainbility and version control is install by using helm.
- Deploy will create automatically : nfs-provisioning namespace, nfs-provisioner pod , nfs-client storage class and the rbac required.

Add the repository to helm and check if be happend.
```
$ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
$ helm repo list
```

Install provisioner and list the deployment in the specific namespace:

```
$ helm install -n nfs-provisioning --create-namespace nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=IP_NFS_ADDR --set nfs.path=/nfs-data
$ helm list --namespace NAMESPACE_NAME
```

For ending you could check the pods that were created and the Storage Class.

```
$ kubectl get all -n nfs-provisioning
$ kubectl get sc -n nfs-provisioning
```

## Deploy the Resources and Application as example

- Let's create a PVC. Keep in mind that PVC needs a Storage Class, and we mentioned prevously as : nfs-client.
- Create a PVC enable the possibility to request storage for your deployment/pod.

### Create a PVC

```
kubectl apply -f 00-poc-nfs-pvc.yml -n nfs-provisioning
```
Check ths PV and PVC was created by the provisioner using the YAML file directly.
```
kubectl get pv -o wide -n nfs-provisioning
kubectl get pvc -o wide -n nfs-provisioning
```
Of course, if your are courious, you could check in some places as logs and NFS server

- by the filsystem in the NFS server.
  ```
  ❯ ls -l /nfs-data
  rwxrwxrwx   2   root   nogroup      4 KiB   Sat Sep 30 10:03:45 2023    nfs-provisioning-poc-nfs-claim-pvc-563c7a41-e707-400a-a482-b33a39a3e160/
  ```

### Create the application demo

```
kubectl apply -f 01-poc-nfs-pod.yml
kubectl logs -f pods/test-pod -n nfs-provisioning
```

- In the NFS you could check the file created by the deployment runned below:
  ```
  ❯ ls -l /nfs-data/nfs-provisioning-poc-nfs-claim-pvc-563c7a41-e707-400a-a482-b33a39a3e160
  rw-r--r--   1   root   root      0 B     Sat Sep 30 10:06:59 2023    POC-NFS-SUCCESS
  ```

## Check inside the pods and controls the /mnt path that contains the file SUCESS

```console
kubectl exec -it poc-nfs-pod -n nfs-provisioning /bin/sh
```

## Delete the filesystem and check the provisioning

``` 
 kubectl delete -f 01-poc-nfs-pod.yml
 kubectl delete -f 00-poc-nfs-pvc.yml
 kubectl get pv,pvc -n nfs-provisioning
```
