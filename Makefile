.PHONY: all build docker release

all : docker
travis : docker release

git_rev := $(shell git rev-parse --short HEAD)
git_tag := $(shell git tag --points-at=$(git_rev))
image := sky-cirrus/cleanup-docker-registry

docker : build
	@echo "== build"
	docker build -t $(image):latest .

release : docker
	@echo "== release"
ifeq ($(strip $(git_tag)),)
	@echo "no tag on $(git_rev), skipping release"
else
	@echo "releasing $(image):$(git_tag)"
	@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
	docker tag $(image):latest $(image):$(git_tag)
	docker push $(image):$(git_tag)
endif
