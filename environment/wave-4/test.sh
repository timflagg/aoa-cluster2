#!/bin/bash

cluster_context="cluster1"


./tools/wait-for-rollout.sh deployment ext-auth-service gloo-mesh-addons 10 ${cluster_context}
./tools/wait-for-rollout.sh deployment rate-limiter gloo-mesh-addons 10 ${cluster_context}
./tools/wait-for-rollout.sh deployment redis gloo-mesh-addons 10 ${cluster_context}

