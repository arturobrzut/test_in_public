#!/bin/bash
echo $IKS_CLUSTER 
ibmcloud ks cluster ls |grep $IKS_CLUSTER 
if [[ $? -eq 0 ]]
then
   echo "."
else
   ibmcloud ks cluster create classic --name $IKS_CLUSTER 
   sleep 5
fi

ibmcloud ks cluster ls |grep $IKS_CLUSTER > log.txt
cat log.txt
cat log.txt | grep normal
if [[ $? -eq 0 ]]
then
   echo "Cluster was created"
   exit 0
else
   echo "Wait creating cluster"
   cat log.txt
   sleep 10
   ./start_iks.sh
fi
