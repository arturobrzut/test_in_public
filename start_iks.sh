#!/bin/bash
export CN=`cat ./clustername.txt`
export IKS_CLUSTER_ZONE=dal10
#ibmcloud ks vlan ls --zone $IKS_CLUSTER_ZONE
export IKS_CLUSTER_PRIVATE_VLAN=2918270
export IKS_CLUSTER_PUBLIC_VLAN=2918268
export IKS_CLUSTER_FLAVOR=u3c.2x4
export IKS_CLUSTER_TAG_NAMES="owner:artur.bereta,team:CP4MCM,Usage:temp,Usage_desc:'Certification tests',Review_freq:month"
echo $CN


if [[ $1 -eq '' ]]
then
        echo "."
else
        echo "Skip creating use this IKS $1"
        exit
fi

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
