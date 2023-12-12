#! /bin/bash

oc get clusterrole,clusterrolebinding,role,rolebinding -o name | grep stackrox | xargs oc delete --wait

oc delete scc -l "app.kubernetes.io/name=stackrox"

oc delete ValidatingWebhookConfiguration stackrox

for namespace in $(oc get ns | tail -n +2 | awk '{print $1}'); do
     oc label namespace $namespace namespace.metadata.stackrox.io/id-;
     oc label namespace $namespace namespace.metadata.stackrox.io/name-;
     oc annotate namespace $namespace modified-by.stackrox.io/namespace-lab
done