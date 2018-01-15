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

REGISTRY_DATA_DIR=${registryVolume} /root/script/clean_old_versions.py \
                                    ${dryRun} \
                                    --image "${patternImage}" \
                                    -l ${nbTagToKeep} \
                                    --order "${orderBeforeDeletion}" \
                                    --registry-url ${registryUrl} > /var/log/clean-images-registry.log

podName=$(hostname)

sleep 2;
if [ ! -z ${podName} ] ; then
  curl -X DELETE -H 'Content-Type: application/yaml' \
  --data 'gracePeriodSeconds: 0' "${urlApiServer}/api/v1/namespaces/${NAMESPACE}/pods/${podName}" -k \
  --header "Authorization: Bearer ${TOKEN_APISERVER}" > /var/log/clean-images-registry.log
fi

