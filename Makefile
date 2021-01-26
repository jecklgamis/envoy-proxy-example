IMAGE_NAME:=jecklgamis/envoy-proxy-template

default:
	@cat ./Makefile
image:
	docker build -t $(IMAGE_NAME):latest .
run:
	docker run -p 80:8080 -p 443:8443 -p 8080:8080 -p 9901:9901 -p 8443:8443 $(IMAGE_NAME):latest
run-bash:
	docker run -i -t $(IMAGE_NAME) /bin/bash
login:
	docker exec -it `docker ps | grep $(IMAGE_NAME) | awk '{print $$1}'` /bin/bash
ssl-certs:
	@./generate-ssl-certs.sh
all: ssl-certs image
push:
	docker image push $(IMAGE_NAME):latest
