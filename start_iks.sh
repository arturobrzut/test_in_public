#!/bin/bash
export RANDFILE=`cat ./random.txt`
export CN=$IKS_CLUSTER$RANDFILE
echo $CN
ibmcloud ks cluster ls |grep $CN
if [[ $? -eq 0 ]]
then
   echo "."
else
   ibmcloud ks cluster create classic --name $CN --flavor $IKS_CLUSTER_FLAVOR --hardware shared --workers 1 --zone dal10
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
   sleep 60
   ./start_iks.sh
fi
