#!/bin/bash
#
# Copyright 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
echo "Start tests"

# ./../operator-sdk run --watch-namespace ibm-common-services --local 2>&1  | tee ./../operator_logs.txt &
./../operator-sdk run --watch-namespace ibm-common-services --local &

echo "List all POD in cluster"
kubectl get pods --all-namespaces
echo "----------------"
echo " "

echo "Wait 10s for checking pod in ibm-common-services. List should be empty"
sleep 10
echo "Pod list:"
kubectl get pods -n ibm-common-services
results="$(kubectl get pods -n ibm-common-services | wc -l)"
if [[ $results -ne "0" ]]
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
fi
echo "Pod list empty: OK"
echo "----------------"
echo " "

echo "Load CR for LS"
cat <<EOF | kubectl apply -f -
  apiVersion: operator.ibm.com/v1alpha1
  kind: IBMLicensing
  metadata:
    name: instance
  spec:
    apiSecretToken: ibm-licensing-token
    datasource: datacollector
    httpsEnable: true
    instanceNamespace: ibm-common-services
EOF
echo "Wait 120s for checking pod in ibm-common-services. List should be one POD"
sleep 120
echo "Pod list:"
kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance
results="$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance | wc -l)"
if [[ $results -ne "1" ]]
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
echo "Pod list 1 record: OK"
echo "Check Pod status"
results="$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance |grep Running |grep '1/1')"
if [[ $results -ne "1" ]]
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
echo "Pod status Running: OK"
echo "----------------"
echo " "

echo "Remove CR from IBMLicensing"
kubectl delete IBMLicensing --all
echo "Wait 120s for checking pod in ibm-common-services. List should be empty"
sleep 120
echo "POD list: "
kubectl get pods -n ibm-common-services
results="$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance | wc -l)"
if [[ $results -ne "0" ]]
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
echo "Pod list empty: OK"
echo "----------------"
exit 0
