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
cd ./ibm-licensing-operator/

curl -Lo ./operator-sdk "https://github.com/operator-framework/operator-sdk/releases/download/v0.17.0/operator-sdk-v0.17.0-x86_64-linux-gnu"
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.9.0/kind-$(uname)-amd64"
chmod +x ./operator-sdk
chmod +x ./kind
./kind create cluster --image kindest/node:v1.17.2
./kind get clusters
kubectl config set-context kind-kind 
kubectl create namespace ibm-common-services
kubectl apply -f ./deploy/crds/operator.ibm.com_ibmlicenseservicereporters_crd.yaml
kubectl apply -f ./deploy/crds/operator.ibm.com_ibmlicensings_crd.yaml
kubectl apply -f ./deploy/service_account.yaml -n ibm-common-services
kubectl apply -f ./deploy/role.yaml
kubectl apply -f ./deploy/role_binding.yaml 
kubectl get pods --all-namespaces
make build
kubectl get pods --all-namespaces
kubectl get pods --all-namespaces

./operator-sdk run --watch-namespace ibm-common-services --local &
sleep 60
kubectl get pods -n ibm-common-services
results = "$(kubectl get pods -n ibm-common-services | wc -l)"
if results -ne "0"
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
echo 3
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
sleep 120
results = "$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance | wc -l)"
if results -ne "1"
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
results = "$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance |grep Running |grep '1/1')"
if results -ne "1"
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
kubectl delete IBMLicensing --all

sleep 120
results = "$(kubectl get pods -n ibm-common-services | grep ibm-licensing-service-instance | wc -l)"
if results -ne "0"
then
  echo "wrong pod ibm-licensing-service-instance"
  kubectl get pods -n ibm-common-services 
  exit 1
fi
