FROM phusion/baseimage:0.9.19

RUN apt-get update && apt-get install -y python python-requests jq \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /root/script

COPY script/* /root/script/

ENV DELETE_DOCKER_FILE_DOWNLOAD_SHA256 1b693885021dd1e903cdc504c78af5b0b73562239bca73f324aab1c4a89f796c
RUN curl --silent -o /usr/local/bin/delete_docker_registry_image \
https://raw.githubusercontent.com/burnettk/delete-docker-registry-image/master/delete_docker_registry_image.py \
    && echo "$DELETE_DOCKER_FILE_DOWNLOAD_SHA256 /usr/local/bin/delete_docker_registry_image" | sha256sum -c -

ENV CLEAN_OLD_VERSIONS_DOWNLOAD_SHA256 694df9f27f48393935ec30d59404f40cc3932cccbc087eb2c0d0d3cf818daca7
RUN curl --silent -o /root/script/clean_old_versions.py \
https://raw.githubusercontent.com/burnettk/delete-docker-registry-image/master/clean_old_versions.py \
    && echo "$CLEAN_OLD_VERSIONS_DOWNLOAD_SHA256 /root/script/clean_old_versions.py" | sha256sum -c -

RUN chmod 0744 /root/script/*
RUN chmod 0744 /usr/local/bin/*

RUN touch /var/log/clean-images-registry.log

# cron schedule
CMD ["/root/script/set-cron.sh"]
