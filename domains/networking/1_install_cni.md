# CNI

## Install flannel

```sh
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

## Install Calico

Find **pod-cidr**:

```
k cluster-info dump | head -n 200
k get pods -n kube-system kube-controller-manager-minikube -oyaml
```

### Simply install

```sh
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```

### Install with tigera-operato

```sh
https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml
```
