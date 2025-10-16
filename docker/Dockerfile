# Stage 1: Compile OpenSSL and Nginx
FROM debian:trixie-slim AS builder

ARG OPENSSL_VERSION
ARG NGINX_VERSION
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /usr/local/src

RUN apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
    build-essential \
    perl \
    wget \
    ca-certificates \
    && (wget -qO openssl-${OPENSSL_VERSION}.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" \
        || { echo "❌ Failed to fetch OpenSSL from GitHub"; exit 1; }) \
    && (wget -qO nginx-${NGINX_VERSION}.tar.gz "https://github.com/nginx/nginx/releases/download/release-${NGINX_VERSION}/nginx-${NGINX_VERSION}.tar.gz" \
        || { echo "❌ Failed to fetch Nginx from GitHub"; exit 1; }) \
    && tar -zxf openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -zxf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && mkdir -p /usr/local/share/nginx \
    && cp -r ./conf /usr/local/share/nginx/ \
    && cp -r ./html /usr/local/share/nginx/ \
    && groupadd --system --gid 101 nginx \
    && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx \
    && ./configure \
         --prefix=/usr/local/nginx \
         --sbin-path=/usr/local/sbin/nginx \
         --conf-path=/etc/nginx/nginx.conf \
         --error-log-path=/var/log/nginx/error.log \
         --pid-path=/var/run/nginx.pid \
         --lock-path=/var/run/nginx.lock \
         --http-log-path=/var/log/nginx/access.log \
         --http-client-body-temp-path=/var/tmp/nginx_tmp/client_body_temp \
         --http-proxy-temp-path=/var/tmp/nginx_tmp/proxy_temp \
         --http-fastcgi-temp-path=/var/tmp/nginx_tmp/fastcgi_temp \
         --http-uwsgi-temp-path=/var/tmp/nginx_tmp/uwsgi_temp \
         --http-scgi-temp-path=/var/tmp/nginx_tmp/scgi_temp \
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
         --with-compat \
         --with-openssl=../openssl-${OPENSSL_VERSION} \
    && make -j$(nproc) \
    && make install

# Stage 2: Final build to make image smaller
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /

COPY --from=builder /usr/local/nginx /usr/local/
COPY --from=builder /usr/local/sbin/nginx /usr/local/sbin/

RUN apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 101 nginx \
    && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/tmp/nginx_tmp/{client_body_temp,proxy_temp,fastcgi_temp,uwsgi_temp,scgi_temp} \
    && chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /var/tmp/nginx_tmp

COPY --from=builder /usr/local/share/nginx/conf /etc/nginx
COPY --from=builder /usr/local/share/nginx/html /usr/local/share/html
COPY configure/nginx.conf /etc/nginx/

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
