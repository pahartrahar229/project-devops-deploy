test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew versionCatalogUpdate

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build

IMAGE_NAME ?= pahartrahar228/project-devops-deploy
IMAGE_TAG ?= latest

.PHONY: docker-build docker-run docker-push

docker-build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

docker-run:
	docker run --rm -p 8080:8080 -p 9090:9090 $(IMAGE_NAME):$(IMAGE_TAG)

docker-push:
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
