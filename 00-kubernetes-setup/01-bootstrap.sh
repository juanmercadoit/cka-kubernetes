# ============================================================================================
# 
# Kubernetes to do:
# 
# Deploy Controlplane.
# Deploy Workers.
# Deploy Networking.
# Add worker to controlplane.
# ============================================================================================
#!/bin/bash

nodetype="$1"

export KUBEVERSION='1.28.2-00'
export CONTROLPLANEIP='192.168.60.11'
export NODEMASTER='controlplane-01'

echo "============================================================================================"
echo ""
echo "[Step 01 - Installing required kube components]"
echo ""
sudo apt update >/dev/null 2>&1

sudo apt install -y curl >/dev/null 2>&1

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - #>/dev/null 2>&1

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" #>/dev/null 2>&1

sudo apt install -y kubeadm=$KUBEVERSION kubelet=$KUBEVERSION kubectl=$KUBEVERSION #>/dev/null 2>&1

sudo apt-mark hold kubeadm kubelet kubectl >/dev/null 2>&1

echo ""
echo "[Step 02 - Install and configure Docker]"
echo ""
sudo apt install -y docker.io >/dev/null 2>&1

sudo systemctl enable docker #>/dev/null 2>&1

sudo cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker #>/dev/null 2>&1

echo "[Step 03 - Disabling swap]"
echo ""
sed -i '/swap/d' /etc/fstab
swapoff -a
echo ""
echo "[Step 04 - Enable IP_Forward]"

sudo modprobe overlay >/dev/null 2>&1

sudo modprobe br_netfilter >/dev/null 2>&1

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system >/dev/null 2>&1
echo ""
echo "[Step 05 -  updating /etc/hosts file]"
echo ""
cat >>/etc/hosts<<EOF
192.168.60.11   controlplane-01.kubernetes.cluster     controlplane-01
192.168.60.21   worker-01.kubernetes.cluster     worker-01
192.168.60.22   worker-02.kubernetes.cluster     worker-02
192.168.60.23   worker-03.kubernetes.cluster     worker-03
192.168.60.24   worker-04.kubernetes.cluster     worker-04
EOF
echo ""
echo "============================================================================================"
echo ""

# 
# Run in controlplane
# Run task in order to deploy a control plane when the condition is equal to "controlplane" 
#
if [ $1 == "controlplane" ]; then
    echo "[Step 2 - Initializing Control Plane Node]"
    sudo kubeadm init --apiserver-advertise-address $CONTROLPLANEIP --control-plane-endpoint $CONTROLPLANEIP --pod-network-cidr=10.244.0.0/16 >/dev/null 2>&1

    echo "============================================================================================"
    echo ""
    echo "[ 01 - CP - Installing Kubernetes network plugin]"
    echo "[ 01 - CP - Enable ssh password authentication]"
    sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "============================================================================================"
    echo ""
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    systemctl reload sshd
    echo "============================================================================================"
    echo ""
    echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
    kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null
    echo ""
    echo -e "COPY and PASTE the contents file /vagrant/DEV.conf and copy into ~/.kube/config \n"
    echo -e "to the machines that you want to run the KUBECTL commands \n"
    echo ""
    cat /etc/kubernetes/admin.conf
    touch /vagrant/DEV.conf
    cat /etc/kubernetes/admin.conf > /vagrant/DEV.conf
    sudo cp /vagrant/DEV.conf ~/.kube/config
    echo "============================================================================================"

fi;
echo ""
echo "============================================================================================"

# Run in each worker node
# Run task in order to deploy a control plane when the condition is equal to "controlplane" 
#
if [ $1 == "worker" ]; then
    echo "[Join worker to cluster]"
    sudo apt install -qq -y sshpass #>/dev/null 2>&1
    sudo sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $NODEMASTER.kubernetes.cluster:/joincluster.sh /vagrant/joincluster.sh #2>/dev/null
    sudo chmod 0777 /vagrant/joincluster.sh 
    sudo bash /vagrant/joincluster.sh #>/dev/null 2>&1
    mkdir ~/.kube
    cp /vagrant/DEV.conf ~/.kube/config
fi;
kubeadm join 192.168.60.11:6443 --token 3sfbuf.hhrwm0a49vh8hq4u --discovery-token-ca-cert-hash sha256:11069e473e84e49a25ace48614afdfa9a1b81696432b86da54fd71774bd83436
echo ""
echo "============================================================================================"