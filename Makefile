IMAGE_NAME:=jecklgamis/envoy-proxy-template
IMAGE_TAG:=$(shell git rev-parse HEAD)

default:
	@cat ./Makefile
image:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
run:
	docker run -p 80:8080 -p 443:8443 -p 8080:8080 -p 9901:9901 -p 8443:8443 $(IMAGE_NAME):$(IMAGE_TAG)
run-bash:
	docker run -i -t $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash
login:
	docker exec -it `docker ps | grep $(IMAGE_NAME) | awk '{print $$1}'` /bin/bash
ssl-certs:
	@./generate-ssl-certs.sh
all: ssl-certs image
up: all run
push:
	docker image push $(IMAGE_NAME):$(IMAGE_TAG)
