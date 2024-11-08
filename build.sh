#!/usr/bin/env bash

# kill nginx service
pkill nginx

WORK_DIR=$PWD
INSTALL_DIR=/opt/build

rm -rf $INSTALL_DIR
mkdir $INSTALL_DIR

# download QuicTLS
rm -rf $WORK_DIR/openssl+quic
mkdir $WORK_DIR/openssl+quic
curl -Ls https://github.com/quictls/openssl/archive/refs/tags/openssl-3.3.0-quic1.tar.gz | tar xzC $WORK_DIR/openssl+quic --strip-components=1


# download OpenResty
rm -rf $WORK_DIR/openresty
mkdir $WORK_DIR/openresty

curl -Ls https://github.com/openresty/openresty/releases/download/v1.25.3.2/openresty-1.25.3.2.tar.gz | tar xzC $WORK_DIR/openresty --strip-components=1
cd $WORK_DIR/openresty
./configure --prefix=$INSTALL_DIR --with-debug --with-openssl=$WORK_DIR/openssl+quic --with-http_ssl_module --with-http_v2_module --with-http_v3_module

make
make install

cd ..

export PATH=$PATH:/opt/build/nginx/sbin

# set cert for http3.cii.com.tw
redis-cli set "ssl_cert:http3.cii.com.tw:cert" "$(cat /etc/letsencrypt/live/http3.cii.com.tw/fullchain.pem)"
redis-cli get "ssl_cert:http3.cii.com.tw:cert"

# set key for http3.cii.com.tw
redis-cli set "ssl_cert:http3.cii.com.tw:key" "$(cat /etc/letsencrypt/live/http3.cii.com.tw/privkey.pem)"
redis-cli get "ssl_cert:http3.cii.com.tw:key"

cp nginx.conf $INSTALL_DIR/nginx/conf/nginx.conf

nginx &



