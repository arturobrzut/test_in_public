#!/usr/bin/env bats
load "lib/utils"
load "lib/detik"
load "lib/linter"

DETIK_CLIENT_NAME="kubectl"
DEBUG_DETIK=true
DETIK_CLIENT_NAMESPACE="ibm-common-services"

@test "simply test" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}


@test "verify the deployment" {
    run verify "there is 1 pod named 'ibm-licensing-operator-'"
    [ "$status" -eq 0 ]
}

