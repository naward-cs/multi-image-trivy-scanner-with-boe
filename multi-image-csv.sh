#!/bin/bash

# Define a list of image names and tags
IMAGES="
calico/cni:v3.30.2
calico/kube-controllers:v3.30.2
calico/node:v3.30.2
calico/pod2daemon-flexvol:v3.30.2
hashicorp/vault:1.20.2
hashicorp/vault-k8s:1.7.0
keycloak/keycloak:26.3.1
library/busybox:1.36.1
wazuh/wazuh-dashboard:4.12.0
wazuh/wazuh-indexer:4.12.0
wazuh/wazuh-manager:4.12.0
public.ecr.aws/eks-distro/coredns/coredns:v1.12.2-eks-1-33-10
public.ecr.aws/eks-distro/etcd-io/etcd:v3.5.16-eks-1-33-10
public.ecr.aws/eks-distro/kubernetes/kube-apiserver:v1.33.3-eks-1-33-10
public.ecr.aws/eks-distro/kubernetes/kube-controller-manager:v1.33.3-eks-1-33-10
public.ecr.aws/eks-distro/kubernetes/kube-proxy:v1.33.3-eks-1-33-10
public.ecr.aws/eks-distro/kubernetes/kube-scheduler:v1.33.3-eks-1-33-10
public.ecr.aws/eks-distro/kubernetes/pause:3.10
public.ecr.aws/eks-distro/kubernetes/pause:v1.33.3-eks-1-33-10
quay.io/jetstack/cert-manager-acmesolver:v1.18.2
quay.io/jetstack/cert-manager-cainjector:v1.18.2
quay.io/jetstack/cert-manager-controller:v1.18.2
quay.io/jetstack/cert-manager-startupapicheck:v1.18.2
quay.io/jetstack/cert-manager-webhook:v1.18.2
quay.io/kubevirt/cdi-apiserver:v1.62.0
quay.io/kubevirt/cdi-cloner:v1.62.0
quay.io/kubevirt/cdi-controller:v1.62.0
quay.io/kubevirt/cdi-importer:v1.62.0
quay.io/kubevirt/cdi-operator:v1.62.0
quay.io/kubevirt/cdi-uploadproxy:v1.62.0
quay.io/kubevirt/cdi-uploadserver:v1.62.0
quay.io/kubevirt/virt-api:v1.6.0
quay.io/kubevirt/virt-controller:v1.6.0
quay.io/kubevirt/virt-handler:v1.6.0
quay.io/kubevirt/virt-launcher:v1.6.0
quay.io/kubevirt/virt-operator:v1.6.0
quay.io/metallb/controller:v0.15.2
quay.io/metallb/speaker:v0.15.2
quay.io/oauth2-proxy/oauth2-proxy:v7.10.0
registry.k8s.io/ingress-nginx/controller:v1.13.1
registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.1
registry.k8s.io/metrics-server/metrics-server:v0.8.0
registry.k8s.io/sig-storage/csi-attacher:v4.9.0
registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.14.0
registry.k8s.io/sig-storage/csi-provisioner:v5.3.0
registry.k8s.io/sig-storage/csi-resizer:v1.14.0
registry.k8s.io/sig-storage/csi-snapshotter:v8.3.0
semaphoreui/semaphore:v2.16.18
freeipa/freeipa-server:rocky-9-4.12.2
"

# Define the output file
OUTPUT_FILE="trivy-report-combined.csv"

# Print the CSV header once
echo '"Image","Target","VulnerabilityID","Severity","PkgName","InstalledVersion","FixedVersion","Title","Description"' > "$OUTPUT_FILE"

# Loop through the images and append the Trivy output
for image in $IMAGES; do
  echo "Scanning $image..."
  trivy image \
    --format template \
    --template "@template-csv-multi-report.tpl" \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --ignore-status unknown,not_affected,will_not_fix \
    "$image" >> "$OUTPUT_FILE"
done