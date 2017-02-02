#!/bin/bash -e

registryVolume="${registryVolume:-}" 
patternImage="${patternImage:-.*}" 
nbTagToKeep="${nbTagToKeep:-20}" 
orderBeforeDeletion="${orderBeforeDeletion:-date}" 
registryUrl="${registryUrl:-http://localhost:5000}" 
urlApiServer="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
TOKEN_APISERVER=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
if [ -z ${dryRun} ]; then dryRun="--dry-run"; else dryRun="" ; fi

export PATH="${PATH}:/root/script"

echo "REGISTRY_DATA_DIR=${registryVolume} \
      /root/script/clean_old_versions.py \
      ${dryRun} \
      --image '${patternImage}' \
      -l ${nbTagToKeep} \
      --order '${orderBeforeDeletion}' \
      --registry-url ${registryUrl} " > /root/script/cron-cleanup-docker-registry-image.sh


echo "podName=\`curl \
                -k --silent \
                --header \"Authorization: Bearer ${TOKEN_APISERVER}\" ${urlApiServer}/api/v1/namespaces/${NAMESPACE}/pods \
                | jq \".items[].metadata.selfLink\" \
                | grep registry | tr -d '\"' \`" >> /root/script/cron-cleanup-docker-registry-image.sh

echo "sleep 2 ; if [! -z \${podName} ] ; then curl -X DELETE -H 'Content-Type: application/yaml' \
--data 'gracePeriodSeconds: 0' \"${urlApiServer}\${podName}\" -k \
--header \"Authorization: Bearer ${TOKEN_APISERVER}\" ; fi" >> /root/script/cron-cleanup-docker-registry-image.sh

chmod 755 /root/script/*

# default each Sunday 0:00
cronTime="${cronTime:-0 0 * * 0}"

echo "${cronTime} /root/script/cron-cleanup-docker-registry-image.sh 2>&1 > /var/log/clean-images-registry.log" > /etc/crontab
crontab /etc/crontab
/sbin/my_init -- tail -f /var/log/clean-images-registry.log
