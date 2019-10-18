# Install multiplass k3s
```
bash <(curl -sfL https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/k3s-multipass.sh)
```
# Install Operator
```
kubectl apply -f \
  https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/manifests/1-create-operator-k3s.yaml
```
# Create Contral Registry Secret
```
USER=YOUR_CONTRAIL_REGISTRY_USER
PWD=YOUR_CONTRAIL_REGISTRY_PASSWORD
kubectl -n contrail create secret docker-registry contrail-nightly \
  --docker-server=hub.juniper.net/contrail-nightly \
  --docker-username=${USER} \
  --docker-password=${PWD}
```
# Install Contrail
```
kubectl apply -f \
  https://raw.githubusercontent.com/michaelhenkel/contrail-k3s/master/manifests/2-start-operator-1node-k3s.yaml
```

