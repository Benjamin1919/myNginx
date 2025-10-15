#!/usr/bin/env bash

CONFIGURE_FLAGS="--prefix=/usr/local/nginx \
--sbin-path=/usr/local/sbin/nginx \
--modules-path=/usr/local/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-log-path=/var/log/nginx/access.log \
--http-client-body-temp-path=/usr/local/nginx/client_body_temp \
--http-proxy-temp-path=/usr/local/nginx/proxy_temp \
--http-fastcgi-temp-path=/usr/local/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/usr/local/nginx/uwsgi_temp \
--http-scgi-temp-path=/usr/local/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-threads \
--with-file-aio \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_v3_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_xslt_module \
--with-http_image_filter_module \
--with-http_geoip_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_auth_request_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_degradation_module \
--with-http_slice_module \
--with-http_stub_status_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module \
--with-stream_geoip_module \
--with-stream_ssl_preread_module \
--with-compat"

echo "CONFIGURE_FLAGS<<EOF" >> $GITHUB_ENV
echo "$CONFIGURE_FLAGS" >> $GITHUB_ENV
echo "EOF" >> $GITHUB_ENV
