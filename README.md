## envoy-proxy 

An Alpine Linux-based Envoy Proxy container. This is a reference implementation for building an Envoy Proxy 
side car for observing your microservice  inbound and outbound traffic, a general reverse proxy, an infrastructure for 
your HTTP fault injection tests, or simply exploring other Envoy Proxy features. See the 
[Envoy Docs](https://www.envoyproxy.io/docs/envoy/latest/) for more info. 

What's inside the container?
* Envoy proxy 
* `app.js`, a minimal HTTP server
* `supervisord`, this enables the Envoy Proxy and `app.js` simultaneously

## Running Locally
#### Clone this repo:

```
git clone git@github.com:jecklgamis/envoy-proxy.git
```

#### Build the Docker container:
```
./generate-ssl-certs.sh
docker build -t jecklgamis/envoy-proxy:latest .
```

#### Run the Docker container:
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

#### Verify default app:
The default app is the minimal `app.js` running on port 8080. The `/` route in `envoy.yaml` points
to the cluster (upstream configuration) that points to this co-located upstream.

```
curl -k https://localhost:8443
```

#### Verify Envo Proxy admin front end:
Point your browser to `http://localhost:9901`. You should be able to see links to other endpoints such as the config, 
cluster, stats, etc.  
```
curl -k  http://localhost:9901
curl -k  http://localhost:9901/stats
curl -k  http://localhost:9901/clusters
curl -k  http://localhost:9901/config_dump
```




 