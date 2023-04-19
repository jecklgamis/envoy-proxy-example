FROM envoyproxy/envoy:v1.26-latest
RUN apt update -y && apt install -y python3 python3-pip curl dumb-init nodejs && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY supervisor.ini /etc/supervisor.d/
RUN mkdir -p /var/log/supervisor

COPY app.js /
COPY run-app.sh /
RUN chmod +x /run-app.sh

COPY run-envoy.sh /
RUN chmod +x /run-envoy.sh
COPY config/envoy* /etc/envoy/
COPY server.crt /etc/
COPY server.key /etc/

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/supervisord","-c","/etc/supervisor.d/supervisor.ini"]
