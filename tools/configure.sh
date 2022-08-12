#!/bin/bash
#set -e

# comma separated list
environment_overlays="apps,cluster-config,infra"

# sed commands to replace target_branch variable
for i in $(echo ${environment_overlays} | sed "s/,/ /g"); do
  kubectl apply -f ../environment/${i}/${i}-aoa.yaml
done