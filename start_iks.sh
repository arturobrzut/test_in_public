#!/bin/bash
export CN=`cat ./clustername.txt`
export IKS_CLUSTER_ZONE=dal10
#ibmcloud ks vlan ls --zone $IKS_CLUSTER_ZONE
export IKS_CLUSTER_PRIVATE_VLAN=2918270
export IKS_CLUSTER_PUBLIC_VLAN=2918268
export IKS_CLUSTER_FLAVOR=u3c.2x4
export IKS_CLUSTER_TAG_NAMES="owner:artur.bereta,team:CP4MCM,Usage:temp,Usage_desc:'Certification tests',Review_freq:month"

if [ -z "$1" ]
then
   echo Cluster which we can ganerate $CN
else
  echo Try to use Cluster  $1
  echo $1 > ./clustername.txt
  ibmcloud ks cluster config --cluster $1  --yaml --admin
  kubectl config current-context
  kubectl get nodes
  echo $?
  kubectl get namespace |grep ibm-common-services
  echo $?
  exit 0
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
   ibmcloud ks cluster config --cluster $CN  --yaml --admin
   kubectl config current-context
   kubectl get nodes
   echo $?
   kubectl get namespace |grep ibm-common-services
   echo $?

  exit 0
else
   echo "Wait creating cluster"
   cat log.txt
   sleep 20
   ./start_iks.sh
fi
