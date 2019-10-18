#!/bin/bash
multipass launch --name k3s1 --mem 6G --disk 10G --cpus 4
multipass exec k3s1 -- sudo rm /etc/resolv.conf
echo nameserver 8.8.8.8 > /tmp/resolv.conf
multipass transfer /tmp/resolv.conf k3s1:/tmp
multipass exec k3s1 -- sudo cp /tmp/resolv.conf /etc/resolv.conf
rm /tmp/resolv.conf
multipass exec k3s1 -- curl -sfL https://get.k3s.io -o /tmp/k3s.sh
multipass exec k3s1 -- chmod +x /tmp/k3s.sh
echo INSTALL_K3S_EXEC=\"server --cluster-cidr=10.32.0.0/12 --service-cidr=10.96.0.0/12 --no-flannel --no-deploy=traefik\" /tmp/k3s.sh > /tmp/k3srunner.sh
multipass transfer /tmp/k3srunner.sh k3s1:/tmp
multipass exec k3s1 -- chmod +x /tmp/k3srunner.sh
multipass exec k3s1 -- /tmp/k3srunner.sh
multipass exec k3s1 -- sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/k3s-config
ip=`multipass exec k3s1 ip r sh |grep default |awk '{print $9}'`
sed -i '' "s/127.0.0.1/${ip}/g" ~/.kube/k3s-config
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/k3s-config
