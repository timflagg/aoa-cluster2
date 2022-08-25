#!/bin/bash

sleep 20

# replace the parameter below with your designated cluster context
# note that the character '_' is an invalid value
#
# please use `kubectl config rename-contexts <current_context> <target_context>` to
# rename your context if necessary
cluster_context="cluster2"
# need to call our mgmt server context to discover LB address
mgmt_context="mgmt"
gloo_mesh_version="2.1.0-beta18"

# discover gloo mesh endpoint with kubectl
until [ "${SVC}" != "" ]; do
  SVC=$(kubectl --context ${mgmt_context} -n gloo-mesh get svc gloo-mesh-mgmt-server -o jsonpath='{.status.loadBalancer.ingress[0].*}')
  echo waiting for gloo mesh management server LoadBalancer IP to be detected
  sleep 2
done

# register clusters to gloo mesh with helm
kubectl apply --context ${cluster_context} -f- <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gm-enterprise-agent-${cluster_context}
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: gloo-mesh
  source:
    repoURL: 'https://storage.googleapis.com/gloo-mesh-enterprise/gloo-mesh-agent'
    targetRevision: ${gloo_mesh_version}
    chart: gloo-mesh-agent
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: cluster
          value: '${cluster_context}'
        - name: relay.serverAddress
          value: '${SVC}:9900'
        - name: relay.authority
          value: 'gloo-mesh-mgmt-server.gloo-mesh'
        - name: relay.clientTlsSecret.name
          value: 'gloo-mesh-agent-${cluster_context}-tls-cert'
        - name: relay.clientTlsSecret.namespace
          value: 'gloo-mesh'
        - name: relay.rootTlsSecret.name
          value: 'relay-root-tls-secret'
        - name: relay.rootTlsSecret.namespace
          value: 'gloo-mesh'
        - name: rate-limiter.enabled
          value: 'false'
        - name: ext-auth-service.enabled
          value: 'false'
        # enabled for future vault integration
        - name: istiodSidecar.createRoleBinding
          value: 'true'
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
    syncOptions:
    - Replace=true
    - ApplyOutOfSyncOnly=true
  project: default
EOF

# wait for completion of bookinfo install
./tools/wait-for-rollout.sh deployment productpage-v1 bookinfo-frontends 10 ${cluster_context}