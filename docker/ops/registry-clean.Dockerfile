FROM curlimages/curl:8.20.0@sha256:eb411f0a02b75f2c2342dbc2f6579905979dd65f61f1b3047067829bb553d149

USER root
RUN apk add --no-cache git openssh-client

USER curl_user
