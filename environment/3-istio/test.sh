#!/bin/bash

if [ "${environment_overlay}" == "ilcm" ]; then
     echo ""
  else 
     #./tools/wait-for-rollout.sh deployment istio-ingressgateway-1-15 istio-gateways 10 ${cluster_context}
     ./tools/wait-for-rollout.sh deployment istio-eastwestgateway-1-15 istio-eastwest 10 ${cluster_context}
  fi

