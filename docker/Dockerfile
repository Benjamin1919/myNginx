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
    && wget -qO openssl-${OPENSSL_VERSION}.tar.gz "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" \
    && wget -qO nginx-${NGINX_VERSION}.tar.gz "https://github.com/nginx/nginx/releases/download/release-${NGINX_VERSION}/nginx-${NGINX_VERSION}.tar.gz" \
    && tar -zxf openssl-${OPENSSL_VERSION}.tar.gz \
    && tar -zxf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure ${CONFIGURE_FLAGS} --with-openssl=../openssl-${OPENSSL_VERSION} \
    && make -j$(nproc) \
    && make install


# Stage 2: Final build to make image smaller
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local/nginx       /usr/local/
COPY --from=builder /usr/local/sbin/nginx  /usr/local/sbin/
COPY --from=builder /etc/nginx             /etc/
COPY --from=builder /var/log/nginx         /var/log/

RUN apt update \
    && apt install --no-install-recommends --no-install-suggests -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 101 nginx \
    && useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx \
    && chown -R nginx:nginx /var/log/nginx

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
