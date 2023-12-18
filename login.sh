#! /bin/bash
CLUSTER=dd-aro
RESOURCEGROUP=aro-main
val=$(az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP )
api=$(az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv)

username=$(echo $val | jq -r ".kubeadminUsername")
password=$(echo $val | jq -r ".kubeadminPassword")

echo oc login -u $username -p $password $api > /opt/homebrew/bin/aro-login
chmod +x /opt/homebrew/bin/aro-login


cat << EOF | kubectl apply -f -
apiVersion: external-secrets.io/v1alpha1
kind: SecretStore
metadata:
  name: azure-backend
  namespace: ekho-external-secrets
spec:
  provider:
    azurekv:
      authType: ManagedIdentity
      environmentType: PublicCloud ##USGovernmentCloud
      tenantId: 64dc69e4-d083-49fc-9569-ebece1dd1408
      identityId: 469f13ac-a9f4-417a-bc92-0eceaed61eca
      vaultUrl: "https://dd-aro-cluster-akv-demo.vault.azure.net/"
---
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: azure-example
  namespace: ekho-external-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: SecretStore
    name: azure-backend
  target:
    name: azure-secret
  data:
  - secretKey: foobar
    remoteRef:
      key: example-externalsecret-key
EOF



