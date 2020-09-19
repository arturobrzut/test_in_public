#!/bin/bash
export CN="license-service$RANDOM"
export IKS_CLUSTER_ZONE=dal10
#ibmcloud ks vlan ls --zone $IKS_CLUSTER_ZONE
export IKS_CLUSTER_PRIVATE_VLAN=2918270
export IKS_CLUSTER_PUBLIC_VLAN=2918268
export IKS_CLUSTER_FLAVOR=u3c.2x4
export IKS_CLUSTER_TAG_NAMES="owner:artur.bereta,team:CP4MCM,Usage:temp,Usage_desc:'Certification tests',Review_freq:month"
rm -f once.txt
if [ -z "$1" ]
then
   echo "try to find cluster license-service"
   ibmcloud oc cluster ls |grep license-service  | grep -m1 normal > once.txt
   if [[ $? -eq 0 ]]
   then
      cat once.txt | awk '{print $1}' >  ./clustername.txt
      export CN=`cat ./clustername.txt`
      echo "Cluser was found $CN"
   fi
else
  echo "You choice to use cluster $1"
  echo $1 > ./clustername.txt
  export CN=`cat ./clustername.txt`
fi
  
ibmcloud ks cluster ls |grep $CN
if [[ $? -eq 0 ]]
then
   echo "Cluster exists"
else
   echo "Start creating cluster $CN"
   ibmcloud oc cluster create classic --name $CN --flavor $IKS_CLUSTER_FLAVOR --hardware shared --workers 1 --zone $IKS_CLUSTER_ZONE --public-vlan $IKS_CLUSTER_PUBLIC_VLAN --private-vlan $IKS_CLUSTER_PRIVATE_VLAN   --public-service-endpoint  --version 4.4_openshift 
   sleep 10
   
   ibmcloud oc cluster ls | grep $CN | grep normal 
   while [ $? -ne 0 ] ; do
     echo "Wait for cluster creation 30s"
     sleep 30
     ibmcloud oc cluster ls |grep $CN | grep normal 
   done  
   echo "Cluster was createdi $CN"
fi

echo "Try to connect to the cluster $CN"
ibmcloud oc cluster config --cluster $CN  --yaml --admin
kubectl config current-context
kubectl get nodes
if [[ $? -ne 0 ]]
then
  echo "ERROR CANNOT GET NODES!!!" 
  exit 1
fi
kubectl get namespace |grep ibm-common-services
i=0
while [ $? -eq 0 ] ; do
    echo "There is namespace ibm-common-services inside cluster. Wait for removing it. Please remove it"
    sleep 2
    i=$i+1
    if [[ $i -gt 10 ]]
    then
        echo "Delete namespace ibm-common-services"
	kubectl delete namespace ibm-common-services
    fi	   
    kubectl get namespace |grep ibm-common-services
done  
echo "There is not ibm-common-services Namespace. It will be create"
kubectl create namespace ibm-common-services
