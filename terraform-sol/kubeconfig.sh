#!/bin/bash

# Switch to the correct kubectl context
kubectx cosmos-mini > /dev/null

# Get the current context and the corresponding cluster name and endpoint
CONTEXT=$(kubectl config current-context)
CLUSTER_NAME=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CONTEXT')].context.cluster}")
ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='$CLUSTER_NAME')].cluster.server}")
CERT_PATH=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='$CLUSTER_NAME')].cluster.certificate-authority}")
CA_CERT=$(cat ${CERT_PATH} | base64 | tr -d '\n')

# Ensure the service account exists
SERVICE_ACCOUNT_NAME="my-user"
kubectl get serviceaccount "$SERVICE_ACCOUNT_NAME" > /dev/null 2>&1 || kubectl create serviceaccount "$SERVICE_ACCOUNT_NAME"

# Create a cluster role binding if not exists
kubectl get clusterrolebinding "$SERVICE_ACCOUNT_NAME"-role-binding > /dev/null 2>&1 || \
kubectl create clusterrolebinding "$SERVICE_ACCOUNT_NAME"-role-binding --clusterrole=cluster-admin --serviceaccount=default:$SERVICE_ACCOUNT_NAME

# Generate a token for the service account
TOKEN=$(kubectl create token "$SERVICE_ACCOUNT_NAME" --duration=24h)

# Output the result in JSON format
echo "{\"endpoint\": \"$ENDPOINT\", \"ca_cert\": \"$CA_CERT\", \"token\": \"$TOKEN\"}"
