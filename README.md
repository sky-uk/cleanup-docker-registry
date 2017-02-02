## Cleanup Docker Registry

The purpose of the image registry/cleanup-registry is to run a cron to clean up the docker images on the docker registry.

It will mount the same volume storage, and restart the docker registry to clean up the cache in memory.

If you don’t restart the Docker registry, if you try to push on an existing tag which is deleted, the response will be “tag already exist”. 

To delete images on the disk, we use this repository https://github.com/burnettk/delete-docker-registry-image


