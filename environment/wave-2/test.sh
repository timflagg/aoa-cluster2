#!/bin/bash

cluster_context="cluster2"

./tools/wait-for-rollout.sh deployment istio-eastwestgateway istio-gateways 10 ${cluster_context}
