#!/bin/bash
#set -e

# replace the parameter below with your designated cluster context
# note that the character '_' is an invalid value
#
# please use `kubectl config rename-contexts <current_context> <target_context>` to
# rename your context if necessary
gloo_mesh_version=${1:-""}
environment_overlay=${2:-prod} # prod, qa, dev, base
cluster_context=${3:-cluster2}
mgmt_context=${4:-mgmt}
github_username=${5:-ably77}
repo_name=${6:-aoa-cluster2}
target_branch=${7:-HEAD}

# check to see if defined contexts exist
if [[ $(kubectl config get-contexts | grep ${cluster_context}) == "" ]] || [[ $(kubectl config get-contexts | grep ${mgmt_context}) == "" ]]; then
  echo "Check Failed: ${cluster_context} context does not exist. Please check to see if you have the clusters available"
  echo "Run 'kubectl config get-contexts' to see currently available contexts. If the clusters are available, please make sure that they are named correctly. Default is ${cluster_context}"
  exit 1;
fi

# check to see if gloo mesh version variable was passed through, if not prompt for it
if [[ ${gloo_mesh_version} == "" ]]
  then
    # provide license key
    echo "Please provide the gloo-mesh agent version to use:"
    read gloo_mesh_version
fi

# install argocd
cd bootstrap-argocd
./install-argocd.sh insecure-rootpath ${cluster_context}
cd ..

# wait for argo cluster rollout
./tools/wait-for-rollout.sh deployment argocd-server argocd 20 ${cluster_context}

# deploy app of app waves
for i in $(ls -l environment/ | grep -v ^total | awk '{print $9}'); do 
  echo "starting ${i}"
  # run init script if it exists
  [[ -f "environment/${i}/init.sh" ]] && ./environment/${i}/init.sh ${i} ${environment_overlay} ${cluster_context} ${github_username} ${repo_name} ${target_branch}
  # deploy aoa wave
  ./tools/configure-wave.sh ${i} ${environment_overlay} ${cluster_context}
  # run test script if it exists
  [[ -f "environment/${i}/test.sh" ]] && ./environment/${i}/test.sh
done

# register agent
./tools/register-agent.sh ${gloo_mesh_version} ${cluster_context} ${mgmt_context}

echo "END."

