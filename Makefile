VENDOR = "Docker curso"
DESCRIPTION = "Cristian Infrastructure Management Image"
AUTHORS = "Cristian OPS team"

NAME = "infra-toolkit"
REPOSITORY = "crcasisdocker/"
REGISTRY_IMAGE ?= $(REPOSITORY)$(NAME)

VERSION ?= "preview"
REVISION = $(shell git rev-parse HEAD)
BUILD_DATE = "$(shell date -u +"%Y-%m-%d %H:%M:%S")"

.PHONY: build
build:
	docker build \
		-t $(REGISTRY_IMAGE):$(VERSION) \
		--build-arg VENDOR=$(VENDOR) \
		--build-arg DESCRIPTION=$(DESCRIPTION) \
		--build-arg AUTHORS=$(AUTHORS) \
		--build-arg VERSION=$(VERSION) \
		--build-arg REVISION=$(REVISION) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		.

.PHONY: push
push:
	docker push $(REGISTRY_IMAGE):$(VERSION)
