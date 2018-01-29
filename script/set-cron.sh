#!/bin/bash -e

# default each Sunday 0:00
cronTime="${cronTime:-0 0 * * 0}"

echo "${cronTime} /bin/bash -l -c '/root/script/cron-cleanup-docker-registry-image.sh 2>&1 > /var/log/clean-images-registry.log'" > /etc/crontab
crontab /etc/crontab
/sbin/my_init -- tail -f /var/log/clean-images-registry.log
