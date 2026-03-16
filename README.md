# ClouderaStreamingOperators
Repo for yaml used in installing Cloudera Streaming Operators


```terminal
# full commands
minikube start --memory 16384 --cpus 6

helm install cert-manager jetstack/cert-manager --version v1.16.3 --namespace cert-manager --create-namespace --set installCRDs=true
helm registry login container.repository.cloudera.com

helm repo update

kubectl create namespace cld-streaming
kubectl create secret generic cfm-operator-license --from-file=license.txt=./license.txt -n cld-streaming
kubectl create secret docker-registry cloudera-creds --docker-server=container.repository.cloudera.com --docker-username=[username] --docker-password=[password] -n cld-streaming

helm install strimzi-cluster-operator --namespace cld-streaming --set 'image.imagePullSecrets[0].name=cloudera-creds' --set-file clouderaLicense.fileContent=./license.txt --set watchAnyNamespace=true oci://container.repository.cloudera.com/cloudera-helm/csm-operator/strimzi-kafka-operator --version 1.6.0-b99

# these are required and vpn must be on for csa!!!!! 
kubectl create -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml
kubectl wait -n cert-manager --for=condition=Available deployment --all

helm install csa-operator --namespace cld-streaming \
    --version 1.5.0-b275 \
    --set 'flink-kubernetes-operator.imagePullSecrets[0].name=cloudera-creds' \
    --set 'ssb.sse.image.imagePullSecrets[0].name=cloudera-creds' \
    --set 'ssb.sqlRunner.image.imagePullSecrets[0].name=cloudera-creds' \
    --set 'ssb.mve.image.imagePullSecrets[0].name=cloudera-creds' \
    --set-file flink-kubernetes-operator.clouderaLicense.fileContent=./license.txt \
    oci://container.repository.cloudera.com/cloudera-helm/csa-operator/csa-operator 

# work in cfm-streaming namespace for nifi
kubectl create namespace cfm-streaming
kubectl create secret generic cfm-operator-license --from-file=license.txt=./license.txt -n cfm-streaming
kubectl create secret docker-registry cloudera-creds --docker-server=container.repository.cloudera.com --docker-username=[username] --docker-password=[password] -n cfm-streaming

# this is the working 2.11 operator command for nifi 1.x & 2.x
helm install cfm-operator oci://container.repository.cloudera.com/cloudera-helm/cfm-operator/cfm-operator \
  --namespace cfm-streaming \
  --version 2.11.0-b57 \
  --set installCRDs=true \
  --set image.repository=container.repository.cloudera.com/cloudera/cfm-operator \
  --set image.tag=2.11.0-b57 \
  --set "image.imagePullSecrets[0].name=cloudera-creds" \
  --set "imagePullSecrets={cloudera-creds}" \
  --set "authProxy.image.repository=container.repository.cloudera.com/cloudera_thirdparty/hardened/kube-rbac-proxy" \
  --set "authProxy.image.tag=0.19.0-r3-202503182126" \
  --set licenseSecret=cfm-operator-license \
  --set-file clouderaLicense.fileContent=./license.txt

# here we will apply any CRs
kubectl apply -f nifi-cluster-2.11-nifi1x.yaml -n cfm-streaming
# nifi 2.0 works 
kubectl apply -f nifi-cluster-2.11-nifi2x.yaml -n cfm-streaming
# now kafka cluster
kubectl apply --filename kafka-eval.yaml,kafka-nodepool.yaml --namespace cld-streaming

# open the UIs
minikube service mynifi-web --namespace cfm-streaming
minikube service cloudera-surveyor-service --namespace cld-streaming
minikube service schema-registry-service --namespace cld-streaming
minikube service ssb-sse --namespace cld-streaming

# uninstall commands
helm uninstall cfm-operator --namespace cld-streaming
helm uninstall cloudera-surveyor --namespace cld-streaming
helm uninstall strimzi-operator --namespace cld-streaming
helm uninstall schema-registry --namespace cld-streaming
helm uninstall csa-operator --namespace cld-streaming

minikube delete

```
