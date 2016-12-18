# A minimalist linux distro
FROM alpine
# Do everything in the home directory
WORKDIR /root
# Install PHP, nginx and development tools, remove system openssl
RUN apk update && \
    apk add wget perl build-base linux-headers
# Download a vulnerable OpenSSL for nginx (patch file is for building on musl libc)
RUN wget -q -O- --no-check-certificate 'https://www.openssl.org/source/openssl-1.0.1f.tar.gz' | tar xz && \
    cd openssl-1.0.1f && \
    wget -q -O- --no-check-certificate 'https://raw.githubusercontent.com/embeddedartists/buildroot/master/package/openssl/openssl-004-musl-termios.patch' | patch -p1
# Install nginx from source
RUN wget -q -O- --no-check-certificate 'https://nginx.org/download/nginx-1.10.2.tar.gz' | tar xz && \
    cd nginx-1.10.2 && \
    ./configure --prefix=/usr/local/nginx \
                --sbin-path=/usr/sbin/nginx \
                --conf-path=/etc/nginx/nginx.conf \
                --pid-path=/run/nginx/nginx.pid \
                --error-log-path=/run/nginx/error.log \
                --http-log-path=/run/nginx/access.log \
                --without-http_gzip_module \
                --without-http_rewrite_module \
                --with-http_ssl_module \
                --with-openssl=/root/openssl-1.0.1f && \
    make && \
    make install
# Do some cleanup
RUN apk del wget perl build-base linux-headers && \
    rm -rf nginx-1.10.2 openssl-1.0.1f /var/cache/apk/*
# Configure cert/key
ADD cert.key /etc/nginx/cert.key
ADD cert.pem /etc/nginx/cert.pem
ADD htpasswd /etc/nginx/.htpasswd
# Configure nginx
ADD nginx.conf /etc/nginx/nginx.conf
# Create the directory for nginx.pid
RUN mkdir -p /run/nginx
# Add the user code
ADD web /srv
# By default on this container, start nginx
CMD /usr/sbin/nginx
# Expose HTTPS port for the internal nginx server
EXPOSE 443
