## envoy-proxy


An Alpine Linux-based Envoy Proxy container. This is a reference implementation for building an Envoy Proxy 
side car for observing your microservice, a general reverse proxy, a test infrastructure for your HTTP fault 
injection tests, or if you're simply exploring Envoy Proxy features. See the [Envoy Docs](https://www.envoyproxy.io/docs/envoy/latest/) 
for more info.

This container runs a statically configured HTTPS listener using port 8443 and routes `/` traffic to a co-located 
upstream `app.js` running on port 8080.

Run the Docker container built in [Docker Hub](https://hub.docker.com/r/jecklgamis/envoy-proxy): 
```
docker run  -p 9901:9901 -p 8443:8443 jecklgamis/envoy-proxy:latest
```
## Running Locally
To build and run locally, follow the steps below. Ensure you have a working Docker environment.

#### Clone this repo:

```
git clone git@github.com:jecklgamis/envoy-proxy.git
```

#### Build the Docker container
```
./generate-ssl-certs.sh
docker build -t jecklgamis/envoy-proxy:latest .
```

#### Run the Docker container
```
docker run  -p 9901:9901 -p 8443:8443 jecklgamis/envoy-proxy:latest
```
Example output:
```
$ docker run  -p 9901:9901 -p 8443:8443 jecklgamis/envoy-proxy:latest
2020-05-04 01:39:09,279 INFO Set uid to user 0 succeeded
2020-05-04 01:39:09,282 INFO supervisord started with pid 8
2020-05-04 01:39:10,290 INFO spawned: 'default-app' with pid 10
2020-05-04 01:39:10,293 INFO spawned: 'envoy-proxy' with pid 11
HTTP server listening on http://0.0.0.0:8080
2020-05-04 01:39:11,386 INFO success: default-app entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2020-05-04 01:39:11,386 INFO success: envoy-proxy entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

#### Verify default app
The default app is the minimal `app.js` running on port 8080. The app simply returns any request body, query params,
or HTTP headers it received. The `/` route in `envoy.yaml` points to the `default_app` cluster that points 
to this co-located upstream.

```
curl -k https://localhost:8443
```
Example output:
```
$ curl -k https://localhost:8443
{"ok":"true","request":{"remote_ip":"::ffff:127.0.0.1","method":"GET","path":"/","headers":{"host":"localhost:8443","user-agent":"curl/7.68.0","accept":"*/*","x-forwarded-proto":"https","x-request-id":"3c641849-de69-4c9e-886c-c429566dd100","x-envoy-expected-rq-timeout-ms":"30000","content-length":"0"},"query":null,"body":""}
```
Here you will notice some HTTP headers with `x-envoy` prefix. This is automatically added by Envoy when it sends the
request to the upstream (`app.js` in this case) and `app.js` simply returns these.

#### Verify Envoy Proxy admin front end
Point your browser to `http://localhost:9901`. You should be able to see links to other endpoints such as the config, 
cluster, stats, etc.  
```
curl -k  http://localhost:9901
curl -k  http://localhost:9901/stats
curl -k  http://localhost:9901/clusters
curl -k  http://localhost:9901/config_dump
```

## SSL Termination
The `envoy.yaml` contains statically configured HTTPS listener on port 8443. This uses a self-signed certificate you 
generated when you build the Docker image. The co-located upstream (`app.js`) receives non-SSL traffic from Envoy.



 