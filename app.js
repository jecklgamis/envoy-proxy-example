const http = require('http');
const url = require('url');

if (process.argv.length <= 2) {
    console.log("Requires port number");
    process.exit();
}

const host = "0.0.0.0";
const port = process.argv[2];

var handler = function (request, response) {
    let body = [];
    const url_parts = url.parse(request.url);
    const request_data = {
        remote_ip: request.connection.remoteAddress,
        method: request.method,
        path: url_parts.pathname,
        headers: request.headers,
        query: url_parts.query
    };
    request.on('data', function (chunk) {
        body.push(chunk);
    }).on('end', function () {
        body = Buffer.concat(body).toString();
        request_data['body'] = body;
        var message = {
            ok: "true",
            request: request_data
        };
        console.log("[app.js:" + port + "] " + JSON.stringify(request_data));
        response.end(JSON.stringify(message))
    });

};


const server = http.createServer(handler);
server.listen(port, function () {
    console.log("HTTP server listening on http://%s:%d", host, port);
});