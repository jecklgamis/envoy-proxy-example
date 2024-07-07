IMAGE_NAME:=envoy-proxy-example
IMAGE_TAG:=$(shell git rev-parse --abbrev-ref HEAD)

default:
	@cat ./Makefile
image:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
run:
	docker run -p 8080:8080 -p 9901:9901 -p 8443:8443 $(IMAGE_NAME):$(IMAGE_TAG)
run-shell:
	docker run -i -t $(IMAGE_NAME):$(IMAGE_TAG) /bin/bash
exec-shell:
	docker exec -it `docker ps | grep $(IMAGE_NAME) | awk '{print $$1}'` /bin/bash
ssl-certs:
	@./generate-ssl-certs.sh
all: ssl-certs image
up: all run
