#! /bin/bash
CLUSTER=dd-aro
RESOURCEGROUP=aro-main
val=$(az aro list-credentials --name $CLUSTER --resource-group $RESOURCEGROUP )
api=$(az aro show -g $RESOURCEGROUP -n $CLUSTER --query apiserverProfile.url -o tsv)

username=$(echo $val | jq -r ".kubeadminUsername")
password=$(echo $val | jq -r ".kubeadminPassword")

echo oc login -u $username -p $password $api > /opt/homebrew/bin/aro-login
chmod +x /opt/homebrew/bin/aro-login




