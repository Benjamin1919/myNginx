# Multi-stage build: build Nginx from source and create a small runtime image.

ARG NGINX_VERSION=1.29.2
ARG OPENSSL_VERSION=3.6.0
ARG NGINX_CONFIGURE_FLAGS=""

FROM debian:bookworm-slim AS build

ARG NGINX_VERSION
ARG OPENSSL_VERSION
ARG NGINX_CONFIGURE_FLAGS

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
ca-certificates build-essential wget curl git ca-certificates \
libpcre3-dev zlib1g-dev libssl-dev perl libxslt1-dev libgd-dev pkgconf \
dpkg-dev devscripts gettext fakeroot \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download upstream sources
RUN wget -q https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
&& tar xzf nginx-${NGINX_VERSION}.tar.gz

RUN wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
&& tar xzf openssl-${OPENSSL_VERSION}.tar.gz

# Prepare build directory
WORKDIR /build/nginx-${NGINX_VERSION}

# If NGINX_CONFIGURE_FLAGS is empty, fall back to a conservative set of flags resembling nginx-full
# The CI will pass the flags extracted from Debian packaging when available.
RUN set -eux; \
if [ -z "${NGINX_CONFIGURE_FLAGS}" ] || [ "${NGINX_CONFIGURE_FLAGS}" = "\"\"" ]; then \
echo "No configure flags passed; using default nginx-full-like flags"; \
NCFG="--prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log --with-compat --with-http_ssl_module \
--with-http_v2_module --with-http_v3_module --with-stream --with-stream_ssl_module \
--with-stream_realip_module --with-stream_ssl_preread_module --with-file-aio --with-threads"; \
else \
# strip surrounding markers if present
NCFG=$(echo ${NGINX_CONFIGURE_FLAGS} | sed 's/^\s*"\?//; s/"\?$//'); \
fi; \
echo "configure flags: $NCFG"; \
./configure ${NCFG} --with-openssl=/build/openssl-${OPENSSL_VERSION} --with-cc-opt='-g -O2' --with-ld-opt='-Wl,-z,relro' ; \
make -j$(nproc) ; \
make install DESTDIR=/build/nginx-install


# Create smaller runtime image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libpcre3 zlib1g libssl3 && rm -rf /var/lib/apt/lists/*

COPY --from=build /build/nginx-install/ /usr/

# Move configuration files into /etc/nginx if they aren't already
RUN mkdir -p /etc/nginx && [ -f /usr/etc/nginx/nginx.conf ] || true

STOPSIGNAL SIGQUIT

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
