FROM envoyproxy/envoy:v1.31-latest
RUN apt update -y && apt install -y curl dumb-init nodejs supervisor && rm -rf /var/lib/apt/lists/*

COPY supervisor.ini /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor

COPY app.js /
COPY run-app.sh /

COPY run-envoy.sh /
COPY config/envoy* /etc/envoy/
COPY server.crt /etc/
COPY server.key /etc/

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisor.d/supervisor.ini"]
