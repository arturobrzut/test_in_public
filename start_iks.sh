#!/bin/sh
ibmcloud ks cluster ls |grep license-service2 
if [ $? == 0 ]
then
   echo "."
else
   ibmcloud ks cluster create classic --name $IKS_CLUSTER 
   sleep 5
fi

ibmcloud ks cluster ls |grep license-service2 > log.txt
cat log.txt
cat log.txt | grep normal
if [ $? == 0 ]
then
   echo "Cluster was created"
   exit 0
else
   echo "Wait creating cluster"
   cat log.txt
   sleep 10
   ./start_iks.sh
fi
