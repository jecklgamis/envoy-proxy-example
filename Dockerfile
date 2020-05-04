FROM envoyproxy/envoy-alpine:v1.14.1

RUN apk update && apk add --no-cache bash curl dumb-init
RUN apk update && apk add --no-cache --update nodejs npm
RUN apk update && apk add --no-cache python3
RUN pip3 install --upgrade pip

COPY requirements.txt /
RUN pip3 install -r /requirements.txt

## supervisor
COPY supervisor.ini /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor

## default app
COPY app.js /
COPY run_app.sh /
RUN chmod +x /run_app.sh

## envoy
COPY run_envoy.sh /
RUN chmod +x /run_envoy.sh
COPY envoy* /etc/envoy/
COPY server.crt /etc/
COPY server.key /etc/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor.d/supervisor.ini"]
