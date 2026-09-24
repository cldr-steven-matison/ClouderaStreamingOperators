#!/bin/bash
# Simple Helm Uninstall Script for Cloudera Streaming Operators

echo "🧹 Starting uninstall of Cloudera Streaming Operators..."

# Uninstall in recommended reverse order
helm uninstall cfm-operator --namespace cfm-streaming || true
helm uninstall cloudera-surveyor --namespace cld-streaming || true
helm uninstall schema-registry --namespace cld-streaming || true
helm uninstall csa-operator --namespace cld-streaming || true
helm uninstall strimzi-cluster-operator --namespace cld-streaming || true

# Optional: also uninstall cert-manager if you installed it
helm uninstall cert-manager --namespace cert-manager || true

echo "✅ All Helm releases uninstalled."

# Delete all the secrets you created
echo "Deleting Cloudera-related secrets..."

# Secrets in CLUSTER_NAMESPACE
kubectl delete secret cfm-operator-license cloudera-creds --namespace "$CLUSTER_NAMESPACE" --ignore-not-found

# Secrets in CFM_NAMESPACE
kubectl delete secret cfm-operator-license cloudera-creds nifi-admin-creds --namespace "$CFM_NAMESPACE" --ignore-not-found

echo "All secrets deleted successfully."

minikube delete

echo "minikube deleted."
