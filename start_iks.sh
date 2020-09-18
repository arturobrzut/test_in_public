#!/bin/bash
export RANDFILE=`cat ./random.txt`
export CN=$IKS_CLUSTER$RANDFILE
export IKS_CLUSTER_ZONE=dal10
export IKS_CLUSTER_PRIVATE_VLAN=2887074
export IKS_CLUSTER_PUBLIC_VLAN=2887072
export IKS_CLUSTER_FLAVOR=u3c.2x4
echo $CN
ibmcloud ks cluster ls |grep $CN
if [[ $? -eq 0 ]]
then
   echo "."
else
   ibmcloud ks cluster create classic --name $CN --flavor $IKS_CLUSTER_FLAVOR --hardware shared --workers 1 --zone $IKS_CLUSTER_ZONE --public-vlan $IKS_CLUSTER_PUBLIC_VLAN --private-vlan $IKS_CLUSTER_PRIVATE_VLAN
   sleep 5
fi

ibmcloud ks cluster ls |grep $CN > log.txt
cat log.txt
cat log.txt | grep normal
if [[ $? -eq 0 ]]
then
   echo "Cluster was created"
   exit 0
else
   echo "Wait creating cluster"
   cat log.txt
   sleep 20
   ./start_iks.sh
fi
