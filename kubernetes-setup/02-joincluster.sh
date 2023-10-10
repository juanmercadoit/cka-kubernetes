# ====================================================================================================================
# 
# Add worker to controlplane.
#
# kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash <ca-cert-hash>
# ====================================================================================================================

kubeadm join 192.168.60.11:6443 --token q4dsgc.kk0roefuwa6gxbo8 --discovery-token-ca-cert-hash sha256:11069e473e84e49a25ace48614afdfa9a1b81696432b86da54fd71774bd83436 
