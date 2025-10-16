# Stage 1: Compile OpenSSL and Nginx
FROM debian:trixie-slim AS builder

ARG OPENSSL_VERSION
ARG NGINX_VERSION
ARG CONFIGURE_FLAGS
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
    && ./configure ${CONFIGURE_FLAGS} \
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
