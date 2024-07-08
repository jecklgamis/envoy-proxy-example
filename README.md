## envoy-proxy-example

[![Build](https://github.com/jecklgamis/envoy-proxy-example/actions/workflows/build.yml/badge.svg)](https://github.com/jecklgamis/envoy-proxy-example/actions/workflows/build.yml)

An example Envoy Proxy. This is a reference implementation for building an Envoy Proxy
sidecar for observing your microservice, a general reverse proxy, a test infrastructure for your HTTP fault
injection tests, or if you're simply exploring Envoy Proxy features. See the [Envoy Docs](https://www.envoyproxy.io/docs/envoy/latest/) 
for more info.

This container runs a statically configured HTTP/HTTPS listener and routes `/` traffic to a co-located 
upstream `app.js` running on port 5050.

Run the Docker image from [Docker Hub](https://hub.docker.com/r/jecklgamis/envoy-proxy-example)

```
docker run -p 8080:8080 -p 9901:9901 -p 8443:8443 jecklgamis/envoy-proxy-example:main
```
## Running Locally
To build and run locally, follow the steps below. Ensure you have a working Docker environment.

#### Clone this repo:

```
git clone git@github.com:jecklgamis/envoy-proxy-example.git
```

#### Build the Docker image
```
./generate-ssl-certs.sh
docker build -t envoy-proxy-example:main .
```

#### Run the Docker image
```
docker run -p 8080:8080  -p 9901:9901 -p 8443:8443 envoy-proxy-example:main
```
Example output:
```
docker run -p 8080:8080 -p 9901:9901 -p 8443:8443 envoy-proxy-example:main
2020-09-02 19:12:01,126 INFO Set uid to user 0 succeeded
2020-09-02 19:12:01,130 INFO supervisord started with pid 6
2020-09-02 19:12:02,098 INFO spawned: 'default-app' with pid 8
2020-09-02 19:12:02,100 INFO spawned: 'envoy-proxy-example' with pid 9
HTTP server listening on http://0.0.0.0:5050
2020-09-02 19:12:03,220 INFO success: default-app entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2020-09-02 19:12:03,221 INFO success: envoy-proxy-example entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

#### Verify default app
The default app is a minimal `app.js` running on port 5050. The app simply returns any request body, query params,
or HTTP headers it receives. The `/` route in `envoy.yaml` points to the `default_app` cluster that points 
to this co-located upstream.

```
curl http://localhost:8080
```
Example output:
```
$ curl http://localhost:8080
{"ok":"true","request":{"remote_ip":"::ffff:127.0.0.1","method":"GET","path":"/","headers":{"host":"localhost:8080","user-agent":"curl/7.68.0","accept":"*/*","x-forwarded-proto":"https","x-request-id":"3c641849-de69-4c9e-886c-c429566dd100","x-envoy-expected-rq-timeout-ms":"30000","content-length":"0"},"query":null,"body":""}
```
Here you will notice some HTTP headers with `x-envoy` prefix. This is automatically added by Envoy when it sends the
request to the upstream (`app.js` in this case) and `app.js` simply returns these.

#### Verify admin front end
Point your browser to `http://localhost:9901`. You should be able to see links to other endpoints such as the config, 
cluster, stats, etc.  
```
curl http://localhost:9901
curl http://localhost:9901/stats
curl http://localhost:9901/clusters
curl http://localhost:9901/config_dump
```

## SSL Termination
The `envoy.yaml` contains statically configured HTTPS listener on port 8443. This uses a self-signed certificate you 
generated when you build the Docker image. The co-located upstream (`app.js`) receives non-SSL traffic from Envoy.


 
