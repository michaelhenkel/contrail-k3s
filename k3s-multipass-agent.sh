#!/bin/bash
if [[ -z ${AGENT_NAME} ]]; then
  AGENT_NAME=k3s2
fi
multipass launch --name ${AGENT_NAME} --mem 2G --disk 8G --cpus 1
multipass exec ${AGENT_NAME} -- sudo rm /etc/resolv.conf
echo nameserver 8.8.8.8 > /tmp/resolv.conf
multipass transfer /tmp/resolv.conf ${AGENT_NAME}:/tmp
multipass exec ${AGENT_NAME} -- sudo cp /tmp/resolv.conf /etc/resolv.conf
rm /tmp/resolv.conf
multipass exec ${AGENT_NAME} -- curl -sfL https://get.k3s.io -o /tmp/k3s.sh
multipass exec ${AGENT_NAME} -- chmod +x /tmp/k3s.sh
masterip=$(multipass info k3s1 |grep IPv4 |awk '{print $2}')
token=$(multipass exec k3s1 -- sudo cat /var/lib/rancher/k3s/server/node-token|tr -d '\015')
echo "INSTALL_K3S_EXEC=\"agent --server https://${masterip}:6443 --token=${token} --no-flannel --node-label=node-role.opencontrail.org=vrouter\" /tmp/k3s.sh" > /tmp/k3srunner.sh
multipass transfer /tmp/k3srunner.sh ${AGENT_NAME}:/tmp
multipass exec ${AGENT_NAME} -- chmod +x /tmp/k3srunner.sh
multipass exec ${AGENT_NAME} -- /tmp/k3srunner.sh
