# Requirement
Multipass (brew install multipass) must be installed

# Installation
## Install Multipass k3s
```
bash <(curl -sfL https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/k3s-multipass.sh)
```
## Install Operator
```
kubectl apply -f \
  https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/manifests/1-create-operator-k3s.yaml
```
## Create Contral Registry Secret
```
USER=YOUR_CONTRAIL_REGISTRY_USER
PWD=YOUR_CONTRAIL_REGISTRY_PASSWORD
kubectl -n contrail create secret docker-registry contrail-nightly \
  --docker-server=hub.juniper.net/contrail-nightly \
  --docker-username=${USER} \
  --docker-password=${PWD}
```
## Install Contrail (depending on internet speed this step can take a few minutes)
```
kubectl apply -f \
  https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/manifests/2-start-operator-1node-k3s.yaml
```
# Watch and wait for all services to be in "Running" state
```
watch kubectl -n contrail get pods -owide
Every 2.0s: kubectl -n contrail get pods -owide                                                        mhenkel-mbp: Thu Oct 17 17:35:09 2019

NAME                                     READY   STATUS    RESTARTS   AGE   IP              NODE   NOMINATED NODE   READINESS GATES
contrail-operator-7bfc6f7f95-h6bqr       1/1     Running   0          16m   192.168.64.73   k3s1   <none>           <none>
rabbitmq1-rabbitmq-statefulset-0         1/1     Running   0          15m   192.168.64.73   k3s1   <none>           <none>
zookeeper1-zookeeper-statefulset-0       1/1     Running   0          15m   192.168.64.73   k3s1   <none>           <none>
cassandra1-cassandra-statefulset-0       1/1     Running   0          15m   192.168.64.73   k3s1   <none>           <none>
config1-config-statefulset-0             9/9     Running   0          14m   192.168.64.73   k3s1   <none>           <none>
kubemanager1-kubemanager-statefulset-0   1/1     Running   0          11m   192.168.64.73   k3s1   <none>           <none>
control1-control-statefulset-0           4/4     Running   0          11m   192.168.64.73   k3s1   <none>           <none>
webui1-webui-statefulset-0               3/3     Running   1          11m   192.168.64.73   k3s1   <none>           <none>
vroutermaster-vrouter-daemonset-9zf4w    3/3     Running   0          10m   192.168.64.73   k3s1   <none>           <none>
```
# Using it
## Create a pod
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: busy1
  annotations:
  labels:
    app: busy1
spec:
  containers:
  - name: busy1
    image: busybox
    command: ["/bin/sh","-c", "while true; do echo hello; sleep 10;done"]
EOF
```
## Watch pod creation
```
watch kubectl get pods -owide
NAME    READY   STATUS    RESTARTS   AGE   IP              NODE   NOMINATED NODE   READINESS GATES
busy1   1/1     Running   0          17s   10.79.255.251   k3s1   <none>           <none>
```
## Access Webui
```
echo "https://$(multipass info k3s1 |grep IPv4 |awk '{print $2}'):8143"
https://192.168.64.73:8143
```
Copy the URL into your browser, username is admin, password is contrail123

