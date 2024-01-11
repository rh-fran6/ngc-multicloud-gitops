#!/bin/bash

aro-login

# Common Variables
CSV_NAME=patterns-operator.v0.0.37

## Conditionally Install Operator
if [[ $(oc get clusterserviceversions $CSV_NAME | awk 'NR >=2 { print $7 }') == "Succeeded" ]]; then
   continue
else

# oc delete clusterserviceversions $CSV_NAME
echo "Installing Patterns subscription"

cat <<EOF | oc apply -f -
  apiVersion: operators.coreos.com/v1alpha1
  kind: Subscription
  metadata:
    name: patterns-operator
    namespace: openshift-operators
    labels:
      operators.coreos.com/patterns-operator.openshift-operators: ""
  spec:
    channel: fast
    installPlanApproval: Automatic
    name: patterns-operator
    source: community-operators
    sourceNamespace: openshift-marketplace
EOF

# sleep 120

fi

# attempt_counter=0
# max_attempts=60

# until [[ $(oc get clusterserviceversions $CSV_NAME | awk 'NR >=2 { print $7 }') == "Succeeded" ]]; do
#     if [ ${attempt_counter} -eq ${max_attempts} ];then
#         echo "Max attempts reached"
#         exit 1
#     fi
#     printf '.'
#     attempt_counter=$(($attempt_counter+1))
#     echo "Made attempt $attempt_counter, waiting..."
#     sleep 5
# done

# fi
    
# CSV_CHECK="$(oc get csv patterns-operator.v0.0.37 -o jsonpath='{.spec.install.spec.deployments[0].spec.template.spec.volumes[0].configMap.name}')"
# VOLUME_INDEX=0
# CONTAINER_0_INDEX=0
# CONTAINER_1_INDEX=1

# # Check CSV and update parameters
# if [[ $CSV_CHECK == "ca-inject" ]]; then
#    echo "Patched already...Updating...."
#    OPERATION="replace"
#    VOLPATH="/spec/install/spec/deployments/0/spec/template/spec/volumes"
#    VOLMOUNTPATH1="/spec/install/spec/deployments/0/spec/template/spec/containers/0/volumeMounts"
#    VOLMOUNTPATH2="/spec/install/spec/deployments/0/spec/template/spec/containers/1/volumeMounts"
# else
#    echo "Patching clusterServiceVersion..."
#    OPERATION="add"
#    VOLPATH="/spec/install/spec/deployments/0/spec/template/spec/volumes"
#    VOLMOUNTPATH1="/spec/install/spec/deployments/0/spec/template/spec/containers/0/volumeMounts"
#    VOLMOUNTPATH2="/spec/install/spec/deployments/0/spec/template/spec/containers/1/volumeMounts"
# fi

# oc -n openshift-operators patch csv/$CSV_NAME --type json -p '[
#   {
#     "op": "'$OPERATION'",
#     "path": "'$VOLPATH'",
#     "value": [
#       {
#         "name": "ca-inject",
#         "configMap": {
#           "name": "ca-inject",
#           "items": [
#             {
#               "key": "ca-bundle.crt",
#               "path": "tls-ca-bundle.pem"
#             }
#           ]
#         }
#       }
#     ]
#   },
#   {
#     "op": "'$OPERATION'",
#     "path": "'$VOLMOUNTPATH1'",
#     "value": [
#       {
#         "name": "ca-inject",
#         "mountPath": "/etc/pki/ca-trust/extracted/pem",
#         "readOnly": true
#       }
#     ]
#   },
#   {
#     "op": "'$OPERATION'",
#     "path": "'$VOLMOUNTPATH2'",
#     "value": [
#       {
#         "name": "ca-inject",
#         "mountPath": "/etc/pki/ca-trust/extracted/pem",
#         "readOnly": true
#       }
#     ]
#   }
# ]'

cat <<EOF | oc apply -f -
apiVersion: gitops.hybrid-cloud-patterns.io/v1alpha1
kind: Pattern
metadata:
  name: ngc
  namespace: openshift-operators
spec:
  clusterGroupName: hub
  gitSpec:
    targetRepo: https://github.com/rh-fran6/ngc-multicloud-gitops.git
    targetRevision: main
  multiSourceConfig:
    enabled: false
EOF

