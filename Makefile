VERSION ?= $(shell git describe --always)
PROJECT := ppl
IMAGE := $(PROJECT)
IMAGE_GIT := $(IMAGE):$(VERSION)
IMAGE_LATEST := $(IMAGE):latest
DOCKER_BUILD := DOCKER_BUILDKIT=1 docker build -t $(IMAGE_LATEST) -t $(IMAGE_GIT)
USER = $(shell id -u):$(shell id -g)
DOCKER_RUN := docker run --rm -it -v $(PWD):/app -u $(USER)

poetry.lock: pyproject.toml
	IMAGE="$(IMAGE):poetry" BUILD_TARGET="poetry" $(DOCKER_BUILD) $
	IMAGE="$(IMAGE):poetry" $(DOCKER_RUN) $(PROJECT) poetry lock --no-interaction -vvv

.PHONY: build
build:
	IMAGE="$(IMAGE):dev" BUILD_TARGET="dev" $(DOCKER_BUILD) .

.PHONY: bash
bash:
	IMAGE="$(IMAGE):dev" \
	$(DOCKER_RUN) $(IMAGE_LATEST) bash
.PHONY: lab
lab:
	IMAGE="$(IMAGE):dev" \
	$(DOCKER_RUN) -p 8896:8896 $(PROJECT) jupyter-lab --allow-root --port=8896 --ip=0.0.0.0

.PHONY: test
test:
	$(DOCKER_RUN) -T $(PROJECT) make _test

.PHONY: _test
_test:
	pytest --junitxml=pytest_junit.xml			\
	--workers auto \
	--cov . --cov-report term-missing --cov-report xml \
	--flake8						\
	--isort							\
	--black							\
	--mypy
