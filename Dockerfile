FROM envoyproxy/envoy-alpine:v1.21-latest

RUN apk update && apk add --no-cache bash curl dumb-init nodejs npm python3 py3-pip
RUN pip install --upgrade pip
COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY supervisor.ini /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor

COPY app.js /
COPY run_app.sh /
RUN chmod +x /run_app.sh

COPY run_envoy.sh /
RUN chmod +x /run_envoy.sh
COPY config/envoy* /etc/envoy/
COPY server.crt /etc/
COPY server.key /etc/

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor.d/supervisor.ini"]
