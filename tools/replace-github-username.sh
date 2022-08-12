# tested on macos
#!/bin/bash
github_username=''$1''
# comma separated list
environment_overlays="apps,cluster-config,infra"

# check to see if github username variable was passed through, if not prompt for key
if [[ ${github_username} == "" ]]
  then
    # provide github username
    echo "Please provide the Github username used to fork this repo:"
    read github_username
fi

# sed commands to replace target_branch variable
for i in $(echo ${environment_overlays} | sed "s/,/ /g"); do
  sed -i '' -e 's/ably77/'${github_username}'/g' ../environment/${i}/${i}-aoa.yaml
done