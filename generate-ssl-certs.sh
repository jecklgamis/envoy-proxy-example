#!/usr/bin/env bash
SERVER_KEY=server.key
SERVER_CERT=server.crt
rm -f ${SERVER_KEY}
rm -f ${SERVER_CERT}
SUBJECT="/C=CC/ST=State/L=Location/O=Org/OU=OrgUnit/CN=envoy-proxy-example"
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ${SERVER_KEY} -out ${SERVER_CERT} -subj ${SUBJECT}
echo "Wrote ${SERVER_KEY}"
echo "Wrote ${SERVER_CERT}"
